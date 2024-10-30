return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = 'VeryLazy',
  keys = {
    { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = '[B]uffer toggle [P]in' },
    { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = '[B]uffer delete non-[P]inned' },
    { '<leader>bo', '<Cmd>BufferLineCloseOthers<CR>', desc = '[B]uffer delete [O]thers' },
    { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = '[B]uffer delete to the [R]ight' },
    { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = '[B]uffer delete to the [L]eft' },
    { '<leader>bc', '<Cmd>bdelete<CR>', desc = '[B]uffer [C]lose' },
    { '<S-h>', '<Cmd>BufferLineCyclePrev<CR>', desc = 'Prev Buffer' },
    { '<S-l>', '<Cmd>BufferLineCycleNext<CR>', desc = 'Next Buffer' },
    { '[b', '<Cmd>BufferLineMovePrev<CR>', desc = 'Move buffer prev' },
    { ']b', '<Cmd>BufferLineMoveNext<CR>', desc = 'Move buffer next' },
  },
  opts = {
    options = {
      diagnostics = 'nvim_lsp',
      always_show_bufferline = false,
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'Neo-tree',
          highlight = 'Directory',
          text_align = 'left',
        },
      },
    },
  },
  config = function(_, opts)
    require('bufferline').setup(opts)
    -- Fix bufferline when restoring a session
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
      callback = function()
        vim.schedule(function()
          pcall(nvim_bufferline)
        end)
      end,
    })
  end,
}
