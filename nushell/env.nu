use std "path add"

path add "/opt/nvim-linux64/bin"
path add "~/.local/bin"
path add "~/.cargo/bin"
path add "/usr/local/go/bin"
path add "~/go/bin"

# fnm
fnm env --json | from json | load-env
path add ($env.FNM_MULTISHELL_PATH + "/bin")
# zoxide
zoxide init nushell | save -f ~/.zoxide.nu

# starship
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
