require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local del = vim.keymap.del

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- delete default binding
del("n", "<Tab>")
del("n", "<S-Tab>")
del("n", "<C-n>")

-- tabufline
map("n", "L", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "H", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })

-- nvimtree
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle" })

-- git blame
map("n", "<leader>gb", function() require("gitsigns").blame_line() end, { desc = "git blame line" })
map("n", "<leader>gB", function() require("gitsigns").blame_line({ full = true }) end, { desc = "git blame line (full)" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
