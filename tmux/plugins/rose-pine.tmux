#!/usr/bin/env bash
#
# Rosé Pine - tmux theme
#
# Almost done, any bug found file a PR to rose-pine/tmux
#
# Inspired by dracula/tmux, catppucin/tmux & challenger-deep-theme/tmux
#

get_tmux_option() {
    local option value default
    option="$1"
    default="$2"
    value="$(tmux show-option -gqv "$option")"

    if [ -n "$value" ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

set() {
    local option=$1
    local value=$2
    tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
    local option=$1
    local value=$2
    tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
    local theme
    theme="$(get_tmux_option "@rose_pine_variant" "")"

    # INFO: Not removing the thm_hl_low and thm_hl_med colors for posible features
    # INFO: If some variables appear unused, they are being used either externally
    # or in the plugin's features
    if [[ $theme == main ]]; then

        thm_base="#191724";
        thm_surface="#1f1d2e";
        thm_overlay="#26233a";
        thm_muted="#6e6a86";
        thm_subtle="#908caa";
        thm_text="#e0def4";
        thm_love="#eb6f92";
        thm_gold="#f6c177";
        thm_rose="#ebbcba";
        thm_pine="#31748f";
        thm_foam="#9ccfd8";
        thm_iris="#c4a7e7";
        thm_hl_low="#21202e";
        thm_hl_med="#403d52";
        thm_hl_high="#524f67";

    elif [[ $theme == dawn ]]; then

        thm_base="#faf4ed";
        thm_surface="#fffaf3";
        thm_overlay="#f2e9e1";
        thm_muted="#9893a5";
        thm_subtle="#797593";
        thm_text="#575279";
        thm_love="#b4637a";
        thm_gold="#ea9d34";
        thm_rose="#d7827e";
        thm_pine="#286983";
        thm_foam="#56949f";
        thm_iris="#907aa9";
        thm_hl_low="#f4ede8";
        thm_hl_med="#dfdad9";
        thm_hl_high="#cecacd";

    elif [[ $theme == moon ]]; then

        thm_base="#232136";
        thm_surface="#2a273f";
        thm_overlay="#393552";
        thm_muted="#6e6a86";
        thm_subtle="#908caa";
        thm_text="#e0def4";
        thm_love="#eb6f92";
        thm_gold="#f6c177";
        thm_rose="#ea9a97";
        thm_pine="#3e8fb0";
        thm_foam="#9ccfd8";
        thm_iris="#c4a7e7";
        thm_hl_low="#2a283e";
        thm_hl_med="#44415a";
        thm_hl_high="#56526e";

    fi

    local tmux_commands=()

    set status on
    set status-style "fg=$thm_pine,bg=default"
    set status-left ""
    set status-right "#{?@pi_ready_count,#[fg=$thm_foam#,bg=default]#[fg=$thm_base#,bg=$thm_foam#,bold] π #{@pi_ready_count} #[fg=$thm_foam#,bg=default],}"
    set status-left-length "200"
    set status-right-length "200"

    set message-style "fg=$thm_muted,bg=default"
    set message-command-style "fg=$thm_base,bg=$thm_gold"

    set pane-border-style "fg=$thm_hl_high"
    set pane-active-border-style "fg=$thm_gold"
    set display-panes-active-colour "$thm_text"
    set display-panes-colour "$thm_gold"

    setw window-status-style "fg=$thm_iris,bg=default"
    setw window-status-activity-style "fg=$thm_rose,bg=default"
    setw window-status-current-style "fg=$thm_gold,bg=default"
    setw window-status-separator "  "

    # Custom centered capsule windows (prefix-aware)
    set status-justify centre
    setw window-status-format "#{?window_start_flag,#[fg=$thm_foam#,bg=default]#[fg=$thm_base#,bg=$thm_foam#,bold] #S #[fg=$thm_foam#,bg=default#,nobold]  ,}#[fg=$thm_overlay,bg=default]#[fg=$thm_subtle,bg=$thm_overlay] #I #W #[fg=$thm_overlay,bg=default]"
    setw window-status-current-format "#{?window_start_flag,#[fg=$thm_foam#,bg=default]#[fg=$thm_base#,bg=$thm_foam#,bold] #S #[fg=$thm_foam#,bg=default]  ,}#[fg=$thm_iris,bg=default]#[fg=$thm_base,bg=$thm_iris,bold] #{?client_prefix,󰘳 ,}#I #W #[fg=$thm_iris,bg=default]"

    setw clock-mode-colour "$thm_love"
    setw mode-style "fg=$thm_gold"

    tmux "${tmux_commands[@]}"
}

main "$@"
