local group = vim.api.nvim_create_augroup('vue_ts_force_sync_parsing', { clear = true })

-- temperary fix for flicking issue
-- remove this when https://github.com/neovim/neovim/issues/32660 is solved
local function update_vue_sync_flag()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'vue' then
      vim.g._ts_force_sync_parsing = true
      return
    end
  end

  vim.g._ts_force_sync_parsing = false
end

vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter', 'BufDelete', 'BufWipeout' }, {
  group = group,
  callback = update_vue_sync_flag,
})

update_vue_sync_flag()
