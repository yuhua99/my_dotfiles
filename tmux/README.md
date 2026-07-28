# Tmux configuration

Terminal multiplexer setup. The configuration lives in `.tmux.conf` at the repository root; this directory holds the rose-pine plugin it loads.

## Requirements

- **Tmux:** Requires tmux 3.4+ because the configuration enables `extended-keys` and `extended-keys-format`; tmux 3.2a reports `invalid option: extended-keys-format` when loading it.
- **Pi jump command:** `prefix+p` requires `~/.pi/agent/extensions/tmux-notify-jump.sh`.
- **Process lookup:** Vim-aware pane navigation uses `ps` to inspect the focused pane's process.

## Installation

- **Setup script:** Run `bash setup.sh` and select the tmux task.
- **Configuration link:** The script links `.tmux.conf` to `~/.tmux.conf`.
- **Plugin link:** The script links `tmux/` to `~/.config/tmux/`; the configuration loads `~/.config/tmux/plugins/rose-pine.tmux`.

## Configuration

- **Prefix:** The prefix is the backtick (`` ` ``) key; `prefix+e` sends a literal backtick.
- **Pane navigation:** `M-h`, `M-j`, `M-k`, and `M-l` use `ps`-based `is_vim` detection, so the same keys transparently cross tmux panes and Vim, Neovim, or fzf splits.
- **Last pane:** `prefix+Tab` returns to the last visited pane across windows and sessions. A `pane-focus-in` hook keeps two-deep `@cur_pane`/`@last_pane` history in server memory, never on disk, and resolves it to an explicit `session:window.pane` target; because it is server-global, attached clients share and overwrite it.
- **Pi integration:** `prefix+p` jumps to ready Pi panes, while `status-right` displays the `@pi_ready_count` capsule.
- **Clipboard:** OSC52 `set-clipboard on` enables copying over SSH.
- **Neovim interop:** `escape-time 10`, `focus-events on`, and RGB true colour are enabled; `focus-events` makes the last-pane hook work.

## Keybindings

### Prefix and sessions

| Key | Action |
| --- | --- |
| `prefix+e` | Send a literal backtick. |
| ``prefix+` `` | Open the zoomed session tree with `choose-tree -Zs`. |
| `prefix+n` | Create or attach to a named session. |
| `prefix+p` | Jump to Pi agent panes reported ready. |
| `prefix+Tab` | Jump to the last visited pane across windows and sessions. |
| `prefix+r` | Reload `~/.tmux.conf`. |

### Windows, panes, and splits

| Key | Action |
| --- | --- |
| `C-h` / `C-l` | Select the previous / next window. |
| `M-h` / `M-j` / `M-k` / `M-l` | Navigate left / down / up / right, or forward the key to a Vim-aware process. |
| `M-i` / `M-o` | Move the current window left / right. |
| `prefix+v` | Split vertically, retaining the current path. |
| `prefix+h` | Split horizontally, retaining the current path. |
| `prefix+c` | Create a window after the current one, retaining the current path. |

### Vi copy mode

| Key | Action |
| --- | --- |
| `v` | Begin selection. |
| `C-v` | Toggle rectangular selection. |
| `y` | Copy the selection, or enter the `y` sub-table when no selection exists. |
| `y`, then `y` | Copy the current line. |
| `y`, then `w` | Copy the current word. |
| `g`, then `g` | Go to the top of history. |
| `g`, then `h` / `l` | Go to the start / end of the line. |
