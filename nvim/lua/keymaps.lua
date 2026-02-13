local map = vim.keymap.set
local nomap = vim.keymap.del
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', 'gl', '$', { desc = 'Go to end of line' })
map('v', 'gl', '$', { desc = 'Go to end of line' })
map('n', 'gh', '^', { desc = 'Go to beginning of line' })
map('v', 'gh', '^', { desc = 'Go to beginning of line' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Oil file explorer
map('n', '<leader>e', '<cmd>Oil<cr>', { desc = 'Open Oil file explorer' })

-- Smart split/pane navigation with tmux fallthrough (Alt+hjkl)
-- If at the edge of nvim splits, falls through to tmux pane switching
local function navigate(dir, tmux_dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. dir)
  if vim.api.nvim_get_current_win() == win then
    vim.fn.system('tmux select-pane -' .. tmux_dir)
  end
end

map('n', '<M-h>', function() navigate('h', 'L') end, { desc = 'Navigate left (vim/tmux)' })
map('n', '<M-l>', function() navigate('l', 'R') end, { desc = 'Navigate right (vim/tmux)' })
map('n', '<M-j>', function() navigate('j', 'D') end, { desc = 'Navigate down (vim/tmux)' })
map('n', '<M-k>', function() navigate('k', 'U') end, { desc = 'Navigate up (vim/tmux)' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- map("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- map("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- map("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- map("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- disable macro recording
map('n', 'q', '<Nop>')

-- Allow q to quit help/checkhealth buffers
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'help', 'checkhealth' },
  callback = function()
    vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = true, desc = 'Quit help/checkhealth buffer' })
  end,
})

-- no yanking to system clipboard for c
vim.api.nvim_set_keymap('n', 'c', '"_c', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'c', '"_c', { noremap = true, silent = true })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
