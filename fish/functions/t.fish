function t --description 'tmux new/attach session'
    if test (count $argv) -eq 1; and test "$argv[1]" = ls
        tmux list-sessions
        return
    end

    tmux new -A -s $argv
end
