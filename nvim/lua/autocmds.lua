local group = vim.api.nvim_create_augroup('big_file', { clear = true })
local MAX_FILE_SIZE = 1024 * 1024 -- 1MB

local function mark_big_file(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then
    return
  end

  local stat = vim.loop.fs_stat(path)
  if not stat or stat.size < MAX_FILE_SIZE then
    return
  end

  vim.b[bufnr].big_file = true
  vim.opt_local.wrap = false
  vim.opt_local.swapfile = false
  vim.opt_local.undofile = false
  vim.opt_local.syntax = 'off'
  vim.opt_local.foldmethod = 'manual'
end

vim.api.nvim_create_autocmd('BufReadPre', {
  group = group,
  callback = function(args)
    if not vim.b[args.buf].big_file then
      mark_big_file(args.buf)
    end
  end,
})
