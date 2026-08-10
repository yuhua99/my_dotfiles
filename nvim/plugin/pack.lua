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

require('pack_ui').setup({
  keymaps = false,
})

vim.keymap.set('n', '<leader>ps', '<cmd>PackStatus<cr>', { desc = 'Plugins: status' })
vim.keymap.set('n', '<leader>pu', '<cmd>PackUpdate<cr>', { desc = 'Plugins: update' })
vim.keymap.set('n', '<leader>pc', pack_clean, { desc = 'Plugins: clean' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'nvim-pack',
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = ev.buf, nowait = true })
  end,
})
