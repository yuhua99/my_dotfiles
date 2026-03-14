complete -c t -e
complete -c t -f -n 'test (count (commandline -opc)) -eq 1' -a 'ls' -d 'list tmux sessions'
complete -c t -f -n 'test (count (commandline -opc)) -eq 1' -a '(tmux list-sessions -F "#{session_name}" 2>/dev/null)' -d 'tmux session'
