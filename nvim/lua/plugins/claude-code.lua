local mapping_key_prefix = "<leader>ac"

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { mapping_key_prefix, group = "Claude Code", mode = { "n", "v" } },
      },
    },
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { mapping_key_prefix .. "a", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { mapping_key_prefix .. "f", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { mapping_key_prefix .. "r", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { mapping_key_prefix .. "C", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { mapping_key_prefix .. "b", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { mapping_key_prefix .. "s", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        mapping_key_prefix .. "s",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      -- Diff management
      { mapping_key_prefix .. "d", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { mapping_key_prefix .. "D", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
