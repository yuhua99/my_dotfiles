local function pack_clean()
  local unused = {}
  for _, plugin in ipairs(vim.pack.get()) do
    if not plugin.active then
      table.insert(unused, plugin.spec.name)
    end
  end
  if #unused == 0 then
    vim.notify('No unused plugins', vim.log.levels.INFO)
    return
  end
  if vim.fn.confirm('Remove unused plugins?', '&Yes\n&No', 2) == 1 then
    vim.pack.del(unused)
  end
end

vim.keymap.set('n', '<leader>pu', vim.pack.update, { desc = 'Plugins: update' })
vim.keymap.set('n', '<leader>ps', function()
  vim.pack.update(nil, { offline = true })
end, { desc = 'Plugins: status' })
vim.keymap.set('n', '<leader>pc', pack_clean, { desc = 'Plugins: clean' })
