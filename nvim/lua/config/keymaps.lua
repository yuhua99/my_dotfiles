-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.del("n", "<leader>l") -- lazy
vim.keymap.del("n", "<leader>L") -- changelog
vim.keymap.del("n", "<leader>-") -- split window
vim.keymap.del("n", "<leader>|") -- split window vertically

-- prevent from yanking into the system clipboard
vim.api.nvim_set_keymap("n", "c", '"_c', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "c", '"_c', { noremap = true, silent = true })
