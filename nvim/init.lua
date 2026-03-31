--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.loader.enable()

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Autocommands ]]
require 'autocmds'

-- [[ Plugin hooks (must be defined BEFORE vim.pack.add) ]]
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind

    -- Rebuild treesitter parsers on install/update
    if name == 'nvim-treesitter' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then
        vim.cmd.packadd 'nvim-treesitter'
      end
      vim.cmd 'TSUpdate'
      return
    end

    -- Build LuaSnip jsregexp on install/update
    if name == 'LuaSnip' and (kind == 'install' or kind == 'update') then
      if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
        return
      end
      local dir = vim.fn.stdpath 'data' .. '/site/pack/core/opt/LuaSnip'
      vim.system({ 'make', 'install_jsregexp' }, { cwd = dir }, function(obj)
        if obj.code ~= 0 then
          vim.schedule(function()
            vim.notify('LuaSnip build failed: ' .. (obj.stderr or ''), vim.log.levels.WARN)
          end)
        end
      end)
    end
  end,
})

-- [[ Install and load ALL eager plugins in one call ]]
vim.pack.add {
  -- UI
  { src = 'https://github.com/rose-pine/neovim', name = 'rose-pine' },

  -- Base
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/rmagatti/auto-session',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/ojroques/nvim-osc52',

  -- Editor
  { src = 'https://github.com/akinsho/bufferline.nvim', version = vim.version.range '*' },
  'https://github.com/ojroques/nvim-bufdel',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/catgoose/nvim-colorizer.lua',
  'https://github.com/lukas-reineke/indent-blankline.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/folke/flash.nvim',
  'https://github.com/windwp/nvim-autopairs',

  -- LSP / Completion
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/j-hui/fidget.nvim',
  { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range '2.x' },
  'https://github.com/rafamadriz/friendly-snippets',
  'https://github.com/giuxtaposition/blink-cmp-copilot',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.x' },
  'https://github.com/neovim/nvim-lspconfig',

  -- AI
  'https://github.com/zbirenbaum/copilot.lua',
}

-- Colorscheme immediately after load
vim.cmd.colorscheme 'rose-pine-moon'

-- [[ Lazy: filetype plugins ]]
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'codecompanion' },
  once = true,
  callback = function()
    vim.pack.add { 'https://github.com/MeanderingProgrammer/render-markdown.nvim' }
    require('render-markdown').setup {
      render_modes = true,
      sign = { enabled = false },
      latex = { enabled = false },
      completions = { blink = { enabled = true } },
    }
    vim.cmd.doautocmd 'FileType'
  end,
})
