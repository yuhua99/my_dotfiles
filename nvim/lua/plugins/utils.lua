return {
  {
    'folke/persistence.nvim',
    event = 'VimEnter',
    opts = {
      options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp' },
    },
    config = function(_, opts)
      require('persistence').setup(opts)

      -- Auto-restore session when starting nvim without arguments
      vim.api.nvim_create_autocmd('VimEnter', {
        group = vim.api.nvim_create_augroup('persistence_auto_restore', { clear = true }),
        callback = function()
          -- Only restore if nvim was started without arguments and no stdin
          if vim.fn.argc(-1) == 0 and not vim.g.started_with_stdin then
            require('persistence').load()
          end
        end,
        nested = true,
      })

      -- Track if started with stdin
      vim.api.nvim_create_autocmd('StdinReadPre', {
        group = vim.api.nvim_create_augroup('persistence_stdin_check', { clear = true }),
        callback = function()
          vim.g.started_with_stdin = true
        end,
      })

      -- Close Lazy windows before session restoration
      vim.api.nvim_create_autocmd('User', {
        pattern = 'PersistenceLoadPre',
        group = vim.api.nvim_create_augroup('persistence_lazy_fix', { clear = true }),
        callback = function()
          -- Check if current buffer is lazy
          if vim.bo.filetype == 'lazy' then
            vim.cmd 'close'
          end

          -- Also check all windows for lazy buffers and close them
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_get_option(buf, 'filetype') == 'lazy' then
              vim.api.nvim_win_close(win, false)
            end
          end
        end,
      })
    end,
  },

  -- autopairs
  -- https://github.com/windwp/nvim-autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' }, -- Load when opening files
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = { 'BufReadPost', 'BufNewFile' }, dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Load after startup but before user interaction
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>a', group = 'Ai' },
        { '<leader>c', group = 'Code' },
        { '<leader>f', group = 'Find' },
        { '<leader>g', group = 'Git' },
        { '<leader>s', group = 'Search' },
        { '<leader>t', group = 'Toggle' },
        { '<leader>u', group = 'Ui' },
      },
    },
  },
}
