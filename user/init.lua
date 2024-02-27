return {
  colorscheme = "catppuccin",
  plugins = {
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.colorscheme.catppuccin" },
    -- language packs
    { import = "astrocommunity.pack.cpp"},
    { import = "astrocommunity.pack.go"},
    -- community plugins
    { import = "astrocommunity.completion.copilot-lua"},
    -- core plugins
    "nvim-telescope/telescope.nvim",
    {
      "nvim-telescope/telescope.nvim",
      dependencies = {
        "nvim-telescope/telescope-live-grep-args.nvim",
      },
      config = function(plugin, opts)
        require("plugins.configs.telescope")(plugin, opts)

        local telescope = require "telescope"
        telescope.load_extension "live_grep_args"
      end,
    },
  },
  mappings = {
    n = {
      ["<leader>fw"] = { function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Find words" }
    }
  },
}
