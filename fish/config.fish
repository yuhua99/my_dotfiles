if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path --global $HOME/.cargo/bin
fish_add_path --global $HOME/.local/bin
fish_add_path --global /opt/homebrew/bin
fish_add_path --global /usr/local/bin

# init plugins
atuin init fish | source
starship init fish | source
zoxide init fish | source
fnm env --use-on-cd --shell fish | source
