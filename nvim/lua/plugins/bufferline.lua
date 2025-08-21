return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'ojroques/nvim-bufdel',
  },
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    options = {
      always_show_bufferline = false,
      custom_filter = function(buf_number)
        local buf_name = vim.fn.bufname(buf_number)
        local buf_ft = vim.fn.getbufvar(buf_number, '&filetype')
        -- Exclude oil buffers and health check buffers
        if buf_ft == 'oil' or buf_ft == 'checkhealth' or string.match(buf_name, 'oil://') then
          return false
        end
        return true
      end,
    },
  },
  keys = {
    { 'H', '<cmd> BufferLineCyclePrev <CR>', mode = 'n' },
    { 'L', '<cmd> BufferLineCycleNext <CR>', mode = 'n' },
    { '<leader>x', '<cmd> BufDel <CR>', desc = 'Close buffer', mode = 'n' },
  },
}
