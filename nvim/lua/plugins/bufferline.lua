local recently_closed = {}

local function track_current_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local bt = vim.bo[buf].buftype

  if name == '' or bt ~= '' then
    return
  end

  table.insert(recently_closed, {
    path = name,
    cursor = vim.api.nvim_win_get_cursor(0),
  })
end

local function close_buffer_and_track()
  track_current_buffer()
  vim.cmd 'BufDel'
end

local function restore_last_closed_buffer()
  local entry = table.remove(recently_closed)

  if not entry then
    vim.notify('No recently closed buffer to restore', vim.log.levels.INFO)
    return
  end

  vim.cmd.edit(vim.fn.fnameescape(entry.path))
  pcall(vim.api.nvim_win_set_cursor, 0, entry.cursor)
end

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
    { '<leader>x', close_buffer_and_track, desc = 'Close buffer', mode = 'n' },
    { '<leader>bo', '<cmd> BufferLineCloseOthers <CR>', desc = 'Close all other buffers', mode = 'n' },
    { '<leader>bx', close_buffer_and_track, desc = 'Close buffer', mode = 'n' },
    { '<leader>br', restore_last_closed_buffer, desc = 'Restore recently closed buffer', mode = 'n' },
  },
}
