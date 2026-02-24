#!/usr/bin/env bash
set -euo pipefail

TMUX_BIN="${TMUX_BIN:-tmux}"
SESSION="$($TMUX_BIN display-message -p '#S')"

get_global_option() {
    local option="$1"
    local default_value="$2"
    local value

    value="$($TMUX_BIN show-option -gqv "$option" 2>/dev/null || true)"
    if [[ -n "$value" ]]; then
        printf '%s' "$value"
    else
        printf '%s' "$default_value"
    fi
}

get_session_option() {
    local option="$1"
    local default_value="$2"
    local value

    value="$($TMUX_BIN show-option -t "$SESSION" -qv "$option" 2>/dev/null || true)"
    if [[ -n "$value" ]]; then
        printf '%s' "$value"
    else
        printf '%s' "$default_value"
    fi
}

set_session_option() {
    local option="$1"
    local value="$2"
    "$TMUX_BIN" set-option -t "$SESSION" -q "$option" "$value"
}

is_positive_int() {
    [[ "$1" =~ ^[0-9]+$ ]] && (( "$1" > 0 ))
}

is_non_negative_int() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

WORK_MINUTES="$(get_global_option '@pomodoro_work_minutes' '25')"
RELAX_MINUTES="$(get_global_option '@pomodoro_relax_minutes' '5')"

if ! is_positive_int "$WORK_MINUTES"; then
    WORK_MINUTES=25
fi

if ! is_positive_int "$RELAX_MINUTES"; then
    RELAX_MINUTES=5
fi

WORK_SECONDS=$((WORK_MINUTES * 60))
RELAX_SECONDS=$((RELAX_MINUTES * 60))

STATE="$(get_session_option '@pomodoro_state' 'stopped')"
MODE="$(get_session_option '@pomodoro_mode' 'focus')"
REMAINING="$(get_session_option '@pomodoro_remaining' "$WORK_SECONDS")"
END_TS="$(get_session_option '@pomodoro_end_ts' '')"

if [[ "$MODE" != "focus" && "$MODE" != "relax" ]]; then
    MODE="focus"
fi

if ! is_non_negative_int "$REMAINING"; then
    if [[ "$MODE" == "relax" ]]; then
        REMAINING="$RELAX_SECONDS"
    else
        REMAINING="$WORK_SECONDS"
    fi
fi

phase_seconds() {
    if [[ "$1" == "relax" ]]; then
        printf '%s' "$RELAX_SECONDS"
    else
        printf '%s' "$WORK_SECONDS"
    fi
}

advance_running_phase() {
    local now="$1"
    local phase_len

    if ! is_non_negative_int "$END_TS"; then
        END_TS=$((now + $(phase_seconds "$MODE")))
    fi

    while (( now >= END_TS )); do
        if [[ "$MODE" == "focus" ]]; then
            MODE="relax"
            phase_len="$RELAX_SECONDS"
        else
            MODE="focus"
            phase_len="$WORK_SECONDS"
        fi
        END_TS=$((END_TS + phase_len))
    done

    REMAINING=$((END_TS - now))
    set_session_option '@pomodoro_mode' "$MODE"
    set_session_option '@pomodoro_end_ts' "$END_TS"
    set_session_option '@pomodoro_remaining' "$REMAINING"
}

toggle() {
    local now
    now="$(date +%s)"

    if [[ "$STATE" == "running" ]]; then
        advance_running_phase "$now"
        set_session_option '@pomodoro_state' 'paused'
        set_session_option '@pomodoro_remaining' "$REMAINING"
        set_session_option '@pomodoro_end_ts' ''
        return
    fi

    if [[ "$STATE" == "paused" ]]; then
        if ! is_positive_int "$REMAINING"; then
            REMAINING="$(phase_seconds "$MODE")"
        fi
        END_TS=$((now + REMAINING))
    else
        MODE='focus'
        REMAINING="$WORK_SECONDS"
        END_TS=$((now + WORK_SECONDS))
        set_session_option '@pomodoro_mode' "$MODE"
    fi

    set_session_option '@pomodoro_state' 'running'
    set_session_option '@pomodoro_remaining' "$REMAINING"
    set_session_option '@pomodoro_end_ts' "$END_TS"
}

stop_timer() {
    set_session_option '@pomodoro_state' 'stopped'
    set_session_option '@pomodoro_mode' 'focus'
    set_session_option '@pomodoro_remaining' "$WORK_SECONDS"
    set_session_option '@pomodoro_end_ts' ''
}

status() {
    local now
    local variant
    local gold
    local foam
    local color
    local minutes
    local seconds

    if [[ "$STATE" == "running" ]]; then
        now="$(date +%s)"
        advance_running_phase "$now"
    elif [[ "$STATE" == "paused" ]]; then
        if ! is_non_negative_int "$REMAINING"; then
            REMAINING="$(phase_seconds "$MODE")"
        fi
    else
        return
    fi

    variant="$(get_global_option '@rose_pine_variant' 'moon')"
    if [[ "$variant" == 'dawn' ]]; then
        gold='#ea9d34'
        foam='#56949f'
    else
        gold='#f6c177'
        foam='#9ccfd8'
    fi

    if [[ "$MODE" == 'relax' ]]; then
        color="$foam"
    else
        color="$gold"
    fi

    minutes=$((REMAINING / 60))
    seconds=$((REMAINING % 60))
    printf '#[fg=%s]%02d:%02d' "$color" "$minutes" "$seconds"
}

case "${1:-status}" in
    toggle)
        toggle
        ;;
    stop)
        stop_timer
        ;;
    status)
        status
        ;;
    *)
        printf 'Usage: %s {toggle|stop|status}\n' "$0" >&2
        exit 1
        ;;
esac
