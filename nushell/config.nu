# default editor
$env.config.buffer_editor = "nvim"

# atuin
source ~/.local/share/atuin/init.nu
# zoxide
source ~/.zoxide.nu

# alias
source ~/.config/nushell/aliases.nu

# auto completions
use ~/.config/nushell/completions.nu *

# starship
use ~/.cache/starship/init.nu
