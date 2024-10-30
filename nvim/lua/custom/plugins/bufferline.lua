return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = 'VeryLazy',
  keys = {
    { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'toggle buffer [P]in' },
    { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'delete non-[P]inned buffers' },
    { '<leader>bo', '<Cmd>BufferLineCloseOthers<CR>', desc = 'delete [O]ther buffers' },
    { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = 'delete to the [R]ight buffer' },
    { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'delete to the [L]eft buffer' },
    { '<leader>bc', '<Cmd>bdelete<CR>', desc = '[C]lose buffer' },
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
