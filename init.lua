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
    { import = "astrocommunity.utility.telescope-live-grep-args-nvim"},
  },
  mappings = {
    n = {
      ["<leader>fw"] = { function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Find words" }
    }
  },
}
