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
del("n", "<leader>ch")
del("n", "<leader>cm")
del("n", "<leader>th")
del("n", "<leader>fm")
del("n", "<leader>pt")
del("n", "<leader>ma")
-- not remapped
del("n", "<leader>rn") -- toggle relative number
del("n", "<leader>n") -- toggle number

-- tabufline
map("n", "L", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "H", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })

-- nvimtree
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle" })

-- git
map("n", "<leader>gb", function()
  require("gitsigns").blame_line()
end, { desc = "git blame line" })
map("n", "<leader>gB", function()
  require("gitsigns").blame_line { full = true }
end, { desc = "git blame line (full)" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "git status" })

-- telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "files" })
map("n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", { desc = "all files" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "help pages" })
map("n", "<leader>fm", "<cmd>Telescope marks<CR>", { desc = "marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "fzf current buffer" })
map("n", "<leader>ft", "<cmd>Telescope terms<CR>", { desc = "terms" })

-- others
map("n", "<leader>wc", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })
map("n", "<leader>ut", function()
  require("nvchad.themes").open()
end, { desc = "nvchad themes" })
map({ "n", "x" }, "<leader>cf", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "format file" })
