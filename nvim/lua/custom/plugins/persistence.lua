return {

  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    -- stylua: ignore
    keys = {
      { '<leader>sr', function() require('persistence').load() end, desc = '[S]ession [R]estore' },
      { '<leader>ss', function() require('persistence').select() end,desc = '[S]ession [S]elect' },
      { '<leader>sl', function() require('persistence').load({ last = true }) end, desc = '[S]ession restore [L]ast one' },
      { '<leader>sd', function() require('persistence').stop() end, desc = "[S]ession [D]on't save current session" },
      { '<leader>sq', '<Cmd>qa<CR>', desc = '[S]ession [Q]uit' },
    },
  },

  -- library used by other plugins
  { 'nvim-lua/plenary.nvim', lazy = true },
}
