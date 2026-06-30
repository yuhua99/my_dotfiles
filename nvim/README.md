# Neovim Configuration

A modern, performance-focused Neovim configuration built on top of [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim) with AI-powered development capabilities.

## ✨ Features

### 🚀 Performance & Modern Architecture
- **Lazy Plugin Loading**: Strategic lazy loading with `lazy.nvim` for optimal startup time
- **Modular Design**: Plugin configurations organized in separate files for maintainability
- **Session Persistence**: Auto-restore previous sessions on startup
- **2-Space Indentation**: Consistent formatting across all file types

### 🤖 AI-Powered Development
- **Smart Completion**: Blink.cmp for modern autocompletion
- **Custom AI Prompts**: Built-in prompts for code explanation, refactoring, testing, and more

### 🔍 Enhanced Navigation & Search
- **FZF-Lua**: Lightning-fast fuzzy finding for files, text, and Git operations
- **FFF**: Alternative file picker built in Rust for speed
- **Flash**: Quick navigation with smart jump motions
- **Oil**: File explorer with buffer-like editing capabilities

### 🎨 Beautiful UI
- **Rose Pine Theme**: Elegant color scheme with excellent syntax highlighting
- **BufferLine**: Clean buffer management with custom filtering
- **Mini.statusline**: Minimalist status line with essential information
- **Which-key**: Discoverable keybindings with helpful popups

### 🛠️ Developer Tools
- **LSP Support**: Full Language Server Protocol support with TypeScript, Vue, and Lua
- **Auto-formatting**: Conform.nvim with Prettier and Stylua formatters
- **Git Integration**: FZF-powered Git status, commits, and file browsing
- **Treesitter**: Advanced syntax highlighting and code understanding

## 📁 Project Structure

```
nvim/
├── init.lua                 # Entry point and basic setup
├── lua/
│   ├── options.lua          # Neovim options and settings
│   ├── keymaps.lua          # Core keybindings
│   ├── lazy-bootstrap.lua   # Lazy.nvim setup
│   ├── lazy-plugins.lua     # Plugin loading configuration
│   └── plugins/             # Modular plugin configurations
│       ├── ai.lua           # Sidekick CLI setup
│       ├── bufferline.lua   # Buffer management
│       ├── editor.lua       # Core editing plugins (completion, formatting, etc.)
│       ├── lspconfig.lua    # Language server configuration
│       ├── oil.lua          # File explorer
│       ├── picker.lua       # FZF-Lua & FFF file pickers
│       ├── ui.lua           # Rose Pine theme
│       └── utils.lua        # Session persistence
└── lazy-lock.json          # Plugin version lock file
```

## ⌨️ Key Bindings

### Core Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `<Space>` | Leader | Main leader key |
| `<C-h/j/k/l>` | Window navigation | Move between splits |
| `<leader>e` | Oil explorer | Open file explorer |
| `s` / `S` | Flash jump | Quick movement with Flash |

### AI Features (CodeCompanion)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ap` | Prompt Actions | Open AI action menu |
| `<leader>aa` | Toggle Chat | Open/close AI chat |
| `<leader>ae` | Explain | Explain selected code |
| `<leader>af` | Fix | Fix selected code |
| `<leader>at` | Tests | Generate unit tests |
| `<leader>am` | Commit | Generate commit message |
| `<leader>aq` | Quick Chat | Quick AI query |

### File Operations
| Key | Action | Description |
|-----|--------|-------------|
| `<leader><space>` | Find Files | FFF file picker |
| `<leader>/` | Live Grep | Search text in project |
| `<leader>fb` | Buffers | Find open buffers |
| `<leader>gf` | Git Files | Find files in Git repo |

### Code Operations
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>cf` | Format | Format current buffer |
| `<leader>ca` | Code Action | LSP code actions |
| `<leader>cr` | Rename | LSP rename symbol |
| `gd` | Definition | Go to definition |
| `gr` | References | Show references |

### Buffer Management
| Key | Action | Description |
|-----|--------|-------------|
| `H` / `L` | Buffer Nav | Previous/next buffer |
| `<leader>x` | Close Buffer | Close current buffer |

## 🔧 Configuration Details

### Core Settings
- **Tab Width**: 2 spaces for all file types
- **Line Numbers**: Relative numbering enabled
- **Clipboard**: Synced with system clipboard
- **Mouse**: Enabled for resize operations
- **Scroll Offset**: 10 lines for better context
- **No Swapfiles**: Disabled for cleaner workspace

### Plugin Highlights

#### Completion System
- **Blink.cmp**: Modern completion engine with fuzzy matching
- **LuaSnip**: Snippet expansion with friendly-snippets
- **Super-tab**: Tab-based completion workflow

#### Language Support
- **TypeScript/Vue**: Full support with vtsls and vue-language-server
- **Lua**: Complete LSP setup with lua_ls
- **Auto-install**: LSPs automatically installed via Mason

#### File Management
- **Oil**: Edit directories like buffers with custom keymaps
- **FZF-Lua**: Feature-rich fuzzy finder with Git integration
- **FFF**: Rust-based file picker for performance

## 🚀 Installation

This configuration is part of a larger dotfiles setup. To install:

```bash
# Clone the dotfiles repository
git clone git@github.com:yuhua99/my_dotfiles.git
cd my_dotfiles

# Setup Neovim configuration
bash setup.sh 2
```

Or manually symlink:
```bash
ln -sf "$PWD/nvim" "$HOME/.config/nvim"
```

## 📦 Dependencies

### Required
- **Neovim 0.11.0+**: Latest stable version recommended
- **Git**: For plugin management and Git operations
- **Node.js**: For TypeScript/JavaScript LSP servers
- **Rust/Cargo**: For FFF file picker compilation

### Optional but Recommended
- **Stylua**: Lua code formatting
- **Prettier**: JavaScript/TypeScript/Vue formatting
- **ripgrep**: Enhanced search performance
- **fd**: Faster file finding

## 🎯 Design Philosophy

This configuration prioritizes:

1. **Performance**: Strategic lazy loading and optimized plugin choices
2. **Developer Experience**: AI assistance for faster development
3. **Simplicity**: Clean, discoverable interface without overwhelming features
4. **Extensibility**: Modular structure for easy customization
5. **Modern Tooling**: Latest Neovim features and plugin ecosystem

## 🔮 AI Workflow

The AI integration enables powerful development workflows:

1. **Code Explanation**: Select code and use `<leader>ae` for AI explanations
2. **Smart Refactoring**: Visual select + `<leader>ar` for AI-powered refactoring
3. **Test Generation**: Highlight functions + `<leader>at` for unit test creation
4. **Commit Messages**: Use `<leader>am` for AI-generated commit messages
5. **Interactive Chat**: `<leader>aa` opens persistent AI chat for complex discussions

The CodeCompanion setup includes custom prompts and seamless integration with the editor, making AI assistance feel natural and non-intrusive.

