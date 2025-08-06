return {
  desc = 'Snacks File Explorer',
  recommended = true,
  'folke/snacks.nvim',
  opts = { explorer = {} },
  keys = {
    {
      '<leader>e',
      function()
        Snacks.explorer()
      end,
      desc = 'Explorer Snacks (cwd)',
    },
  },
}
