if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path --global $HOME/.cargo/bin
fish_add_path --global $HOME/.local/bin
fish_add_path --global $HOME/.limbo
fish_add_path --global /opt/homebrew/bin
fish_add_path --global /usr/local/bin

# init plugins
starship init fish | source
zoxide init fish | source
fnm env --use-on-cd --shell fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Set up fzf key bindings
fzf --fish | source

# proto
set -gx PROTO_HOME "$HOME/.proto";
set -gx PATH "$PROTO_HOME/shims" "$PROTO_HOME/bin" $PATH;
