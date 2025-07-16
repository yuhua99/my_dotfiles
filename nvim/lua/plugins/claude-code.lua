return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  config = function()
    require("claude-code").setup({
      window = {
        position = "vertical", -- edgy will manage the actual positioning
        split_ratio = 0.3,
      },
      command = "claude", -- Command used to launch Claude Code
      command_variants = {
        -- Conversation management
        continue = "--continue", -- Resume the most recent conversation
        resume = "--resume", -- Display an interactive conversation picker

        -- Output options
        verbose = "--verbose", -- Enable verbose logging with full turn-by-turn output
      },
      -- Keymaps
      keymaps = {
        toggle = {
          normal = "<leader>aa", -- Normal mode keymap for toggling Claude Code, false to disable
          terminal = "<C-a>", -- Terminal mode keymap for toggling Claude Code, false to disable
          variants = {
            continue = "<leader>aC", -- Normal mode keymap for Claude Code with continue flag
            verbose = "<leader>aV", -- Normal mode keymap for Claude Code with verbose flag
          },
        },
        window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
        scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
      },
    })
  end,
}
