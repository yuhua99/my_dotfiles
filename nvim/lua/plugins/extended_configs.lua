return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { -- add a new dependency to telescope that is our new plugin
      "nvim-telescope/telescope-media-files.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    -- the first parameter is the plugin specification
    -- the second is the table of options as set up in Lazy with the `opts` key
    config = function(plugin, opts)
      -- run the core AstroNvim configuration function with the options table
      require "astronvim.plugins.configs.telescope"(plugin, opts)
      require("telescope").setup {
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<Tab>"] = require("telescope-live-grep-args.actions").quote_prompt { postfix = " -g *." },
                ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt { postfix = " --iglob " },
              },
            },
          },
        },
      }

      -- require telescope and load extensions as necessary
      require("telescope").load_extension "media_files"
      require("telescope").load_extension "live_grep_args"
    end,
  },
}
