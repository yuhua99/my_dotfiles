return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-3.7-sonnet-thought",
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          keymaps = {
            close = {
              modes = { n = "q" },
            },
            stop = {
              modes = { n = "<C-c>", i = "<C-c>" },
            },
            send = {
              callback = function(chat)
                vim.cmd("stopinsert")
                chat:submit()
              end,
            },
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "folke/edgy.nvim",
      "nvim-lualine/lualine.nvim",
    },
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      {
        "<leader>aa",
        function()
          return require("codecompanion").toggle()
        end,
        desc = "Toggle (CompanionChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        "<cmd>CodeCompanionActions<cr>",
        desc = "Prompt Actions (CompanionChat)",
        mode = { "n", "v" },
      },
    },
    config = function(_, opts)
      local spinner = require("plugins.code-companion.spinner")
      local lualine_loaded, lualine = pcall(require, "lualine")
      if lualine_loaded then
        -- Get current config or create new one
        local config = lualine.get_config()

        -- Add our spinner to the lualine_x section (or another section of your choice)
        table.insert(config.sections.lualine_x, 1, spinner)

        -- Refresh lualine with the updated config
        lualine.setup(config)
      end

      -- Setup the entire opts table
      require("codecompanion").setup(opts)
    end,
  },
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.animate = { enabled = false }
      opts.right = opts.right or {}
      table.insert(opts.right, {
        ft = "codecompanion",
        title = "Companion Chat",
        size = { width = 60 },
      })
    end,
  },
}
