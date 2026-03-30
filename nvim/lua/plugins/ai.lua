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
