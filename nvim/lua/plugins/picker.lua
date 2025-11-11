return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('fzf-lua').setup {
        previewers = {
          builtin = {
            syntax_limit_b = 1024 * 100, -- 100KB
          },
        },
      }
      -- fzf-lua as vim.ui.select interface
      require('fzf-lua').register_ui_select()
    end,
    keys = {
      { 'fw', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep' },
      { 'ff', '<cmd>FzfLua files<cr>', desc = 'Open file picker' },
      { '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Find buffers' },
      { '<leader>fr', '<cmd>FzfLua resume<cr>', desc = 'Resume' },
      { '<leader>fs', '<cmd>FzfLua grep_cword<cr>', desc = 'Search word under cursor' },
      { '<leader>fw', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep' },
      { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Open file picker' },
      { '<leader>gs', '<cmd>FzfLua git_status<cr>', desc = 'Git status' },
      { '<leader>gc', '<cmd>FzfLua git_commits<cr>', desc = 'Git commits' },
      { '<leader>cR', '<cmd>FzfLua lsp_references<cr>', desc = 'Fzf references' },
      { '<leader>cD', '<cmd>FzfLua lsp_definitions<cr>', desc = 'Fzf definitions' },
      { '<leader>cs', '<cmd>FzfLua lsp_document_symbols<cr>', desc = 'Document symbols' },
      { '<leader>fh', '<cmd>FzfLua helptags<cr>', desc = 'Help tags' },
      { '<leader>gf', '<cmd>FzfLua git_files<cr>', desc = 'Git files' },
    },
  },
}
