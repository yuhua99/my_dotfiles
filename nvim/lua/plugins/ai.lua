local mapping_key_prefix = '<leader>a'

return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    build = ':Copilot auth',
    event = 'BufReadPost',
    config = function()
      require('copilot').setup {
        suggestion = { enable = false },
        panel = { enable = false },
      }
    end,
  },
  {
    'folke/sidekick.nvim',
    event = 'VeryLazy',
    opts = {
      cli = {
        win = {
          keys = {
            nav_left = { '<M-h>', 'nav_left', expr = true, desc = 'Go to left window' },
            nav_right = { '<M-l>', 'nav_right', expr = true, desc = 'Go to right window' },
          },
        },
      },
    },
    keys = {
      {
        mapping_key_prefix .. 'a',
        function()
          require('sidekick.cli').toggle()
        end,
        desc = 'Sidekick Toggle CLI',
      },
      {
        mapping_key_prefix .. 's',
        function()
          require('sidekick.cli').select()
        end,
        desc = 'Sidekick Select CLI',
      },
      {
        mapping_key_prefix .. 'p',
        function()
          require('sidekick.cli').prompt()
        end,
        mode = { 'n', 'x' },
        desc = 'Sidekick Prompt',
      },
      {
        mapping_key_prefix .. 'c',
        function()
          require('sidekick.cli').toggle { name = 'codex', focus = true }
        end,
        desc = 'Sidekick Codex',
      },
      {
        mapping_key_prefix .. 'o',
        function()
          require('sidekick.cli').toggle { name = 'opencode', focus = true }
        end,
        desc = 'Sidekick OpenCode',
      },
      {
        mapping_key_prefix .. 'f',
        function()
          require('sidekick.cli').send { msg = '{file}' }
        end,
        desc = 'Sidekick Send File',
      },
      {
        mapping_key_prefix .. 'v',
        function()
          require('sidekick.cli').send { msg = '{selection}' }
        end,
        mode = 'x',
        desc = 'Sidekick Send Selection',
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    main = 'nvim-treesitter.config',
    opts = { ensure_installed = { 'yaml', 'markdown' } },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
    opts = {
      render_modes = true, -- Render in ALL modes
      sign = {
        enabled = false, -- Turn off in the status column
      },
      latex = {
        enabled = false, -- Disable LaTeX rendering
      },
      completions = { blink = { enabled = true } },
    },
  },
}
