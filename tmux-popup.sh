#!/bin/bash

# Automatically fetch the current window ID and session name
window_id=$(tmux display-message -p '#I')
current_session_name=$(tmux display-message -p '#S')

# Fetch the current directory of the parent session
parent_session_dir=$(tmux display-message -p -F "#{pane_current_path}" -t0)

# Construct the unique session name with a "floating" suffix
session_name="floating_${current_session_name}_${window_id}"

startup_command="$1"

# Check if the floating popup session already exists
if tmux has-session -t "$session_name" 2>/dev/null; then
    if [ -n "$startup_command" ]; then
        # If a startup command is provided, look for its process in the list of panes
        target_pane=$(tmux list-panes -a -F "#{session_name} #{pane_id} #{window_name}" | grep -i "^$session_name" | grep -i "$(echo $startup_command | cut -d' ' -f1)" | awk '{print $2}')
        switch_command=""
        if [ -z "$target_pane" ]; then
            # If the process is not found, create a new window with the startup_command in target session
            window_name=$(echo $startup_command | cut -d' ' -f1)
            tmux new-window -t "$session_name" -n "$window_name" -c "$parent_session_dir" "$startup_command"
        else
            # If the process is found, switch to that window
            switch_command="tmux select-window -t $(tmux display-message -p -F "#{window_index}" -t"$target_pane") ;"
        fi
    fi
    tmux popup -w 90% -h 80% -E "bash -c \"tmux attach -t $session_name; $switch_command\""  # Attach to the session in a popup
else
    if [ -z "$startup_command" ]; then
        # If no startup command is provided, just open a shell
        tmux new-session -d -s "$session_name" -c "$parent_session_dir"
    else
        # If a startup command is provided, run it in the new session
        window_name=$(echo $startup_command | cut -d' ' -f1)
        tmux new-session -d -s "$session_name" -c "$parent_session_dir" "$startup_command"
        tmux rename-window -t "$session_name":1 "$window_name"
    fi
    tmux popup -w 90% -h 80% -E "bash -c \"tmux attach -t $session_name\""  # Attach to the session in a popup
fi
