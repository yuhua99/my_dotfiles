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
            vim.cmd('close')
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
}
