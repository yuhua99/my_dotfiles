# My dotfiles

This repository contains my personal configuration files (dotfiles) for various tools.

## Managed Configurations

*   **Neovim:** Configuration based on [LazyVim](https://www.lazyvim.org/).
*   **Tmux:** Terminal multiplexer setup.
*   **Git:** Git configuration, including aliases and settings.
*   **Alacritty:** Terminal emulator configuration.
*   **Nushell:** Configuration for the Nu shell.
*   **MCPHub:** Server configuration for the MCPHub Neovim plugin.

## Prerequisites

*   **Git:** Requires [delta](https://github.com/dandavison/delta) for enhanced diff viewing.
*   **Tmux:** Requires [tpm](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager). Make sure to install plugins with `prefix + I` after setup.
*   **Neovim:** Requires a recent version of Neovim.
*   **Alacritty:** Requires Alacritty terminal emulator.
*   **Nushell:** Requires Nushell.

## 🛠️ Installation

1.  **Clone the repository:**
    ```shell
    git clone git@github.com:yuhua99/my_dotfiles.git
    cd my_dotfiles
    ```
2.  **Run the setup script:**
    ```shell
    bash setup.sh
    ```
    *(Review `setup.sh` to understand what it does before running it).*

## Notes

*   **Git:** Remember to change the `name` and `email` in `.gitconfig` to your own details.
*   **Neovim:** This setup uses LazyVim. Refer to the LazyVim documentation for details on customization.
