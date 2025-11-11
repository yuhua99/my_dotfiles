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
        grep = {
          rg_glob = true,
          -- first returned string is the new search query
          -- second returned string are (optional) additional rg flags
          -- @return string, string?
          -- e.g. hello -- -tts will search for hello strings in ts files
          rg_glob_fn = function(query, opts)
            local regex, flags = query:match '^(.-)%s%-%-(.*)$'
            -- If no separator is detected will return the original query
            return (regex or query), flags
          end,
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
      -- Override default LSP keymaps
      { 'gd', '<cmd>FzfLua lsp_definitions<cr>', desc = 'Go to definition' },
      { 'gR', '<cmd>FzfLua lsp_references<cr>', desc = 'Go to references' },
      { 'gi', '<cmd>FzfLua lsp_implementations<cr>', desc = 'Go to implementation' },
    },
  },
}
