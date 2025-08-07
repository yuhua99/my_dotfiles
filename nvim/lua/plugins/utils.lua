return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 0,
      spec = {
        { '<leader>c', group = 'Code'},
        { '<leader>d', group = 'Diagnostic' },
        { '<leader>f', group = 'Find' },
        { '<leader>g', group = 'Git' },
        { '<leader>u', group = 'Ui' },
        { '<leader>w', group = 'Which key' },
      }
    }
  },
}
