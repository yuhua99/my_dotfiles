return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    options = {
      always_show_bufferline = false,
    },
  },
  keys = {
    { 'H', '<cmd> BufferLineCyclePrev <CR>', mode = 'n' },
    { 'L', '<cmd> BufferLineCycleNext <CR>', mode = 'n' },
    { '<leader>x', '<cmd> bd <CR>', desc = 'Close buffer', mode = 'n' },
  },
}
