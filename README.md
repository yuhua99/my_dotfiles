# My dotfiles

This repository contains my personal configuration files (dotfiles) for various tools.

## Managed Configurations

*   **Neovim:** My own configuration.
*   **Tmux:** Terminal multiplexer setup.
*   **Zellij:** Opinionated keymap with vi-style navigation.
*   **Git:** Git configuration, including aliases and settings.
*   **Alacritty:** Terminal emulator configuration.
*   **Starship:** Cross-shell prompt configuration.

## Prerequisites

*   **Git:** Requires [delta](https://github.com/dandavison/delta) for enhanced diff viewing.
*   **Tmux:** Requires tmux.
*   **Zellij:** Install Zellij 0.40+ for the custom keybinds defined in `zellij/config.kdl`.
*   **Neovim:** Requires a recent version of Neovim.
*   **Alacritty:** Requires Alacritty terminal emulator.
*   **Starship:** Requires Starship to be installed.

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
*   **Zellij:** Starts in locked mode. Hit `Ctrl+a` to enter normal mode. `n`/`d` create panes (horizontal/vertical), `tab` switches focus, `[`/`]` break panes into new tabs, `f` toggles fullscreen, and `Ctrl+a` again returns to locked mode.
