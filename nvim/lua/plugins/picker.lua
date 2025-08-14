return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      fzf_opts = { ['--layout'] = 'default' },
      winopts = {
        height = 0.8, -- window height
        width = 0.8, -- window width
        row = 0.5,
        border = 'single',
        title_pos = 'left', -- 'left', 'center' or 'right'
        preview = {
          border = 'single', -- preview border: accepts both `nvim_open_win`
          title_pos = 'left', -- left|center|right, title alignment
        },
      },
    },
    keys = {
      { '<leader>/', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep' },
      { '<leader>fw', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep' },
      { '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Find buffers' },
      { '<leader>fs', '<cmd>FzfLua grep_cword<cr>', desc = 'Search word under cursor' },
      { '<leader>gs', '<cmd>FzfLua git_status<cr>', desc = 'Git status' },
      { '<leader>gc', '<cmd>FzfLua git_commits<cr>', desc = 'Git commits' },
      { '<leader>cR', '<cmd>FzfLua lsp_references<cr>', desc = 'Fzf references' },
      { '<leader>cD', '<cmd>FzfLua lsp_definitions<cr>', desc = 'Fzf definitions' },
      { '<leader>cs', '<cmd>FzfLua lsp_document_symbols<cr>', desc = 'Document symbols' },
      { '<leader>fh', '<cmd>FzfLua helptags<cr>', desc = 'Help tags' },
    },
  },
  {
    'dmtrKovalenko/fff.nvim',
    build = 'cargo build --release',
    opts = {
      prompt = '> ',
      layout = {
        prompt_position = 'bottom',
      },
    },
    keys = {
      {
        '<leader> ',
        function()
          require('fff').find_files()
        end,
        desc = 'Open file picker',
      },
      {
        '<leader>ff',
        function()
          require('fff').find_files()
        end,
        desc = 'Open file picker',
      },
      {
        '<leader>gf',
        function()
          require('fff').find_in_git_root()
        end,
        desc = 'Git files',
      },
    },
  },
}
