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
      "folke/noice.nvim", -- For status update
      "folke/edgy.nvim",
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
      -- Check for Noice plugin
      local noice_ok, noice = pcall(require, "noice")

      if not noice_ok then
        vim.notify("Noice not found, CodeCompanion status updates disabled.", vim.log.levels.WARN)
        return
      end

      -- Variable to store the notification ID
      local notification_id = nil

      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionRequest*",
        group = vim.api.nvim_create_augroup("CodeCompanionNoiceHooks", { clear = true }), -- Use clear = true to avoid duplicates on reload
        callback = function(args)
          if args.match == "CodeCompanionRequestStarted" then
            -- Dismiss previous notification if any exists
            if notification_id then
              pcall(noice.dismiss, notification_id) -- Wrap dismiss in pcall for safety
              notification_id = nil
            end
            -- Show a new "Thinking..." notification
            notification_id = noice.notify("Thinking...", vim.log.levels.INFO, {
              title = "CodeCompanion",
              name = "codecompanion", -- Associate with the plugin
            })
          elseif args.match == "CodeCompanionRequestFinished" then
            -- If there's an active notification, dismiss it
            if notification_id then
              pcall(noice.dismiss, notification_id) -- Wrap dismiss in pcall for safety
              notification_id = nil -- Reset the ID
              -- Optionally, show a brief "Done" message
              noice.notify("Done.", vim.log.levels.INFO, {
                title = "CodeCompanion",
                timeout = 2000, -- Show for 2 seconds
                name = "codecompanion", -- Associate with the plugin
              })
            end
          elseif args.match == "CodeCompanionRequestError" then
            -- If there's an active notification, dismiss it
            if notification_id then
              pcall(noice.dismiss, notification_id) -- Wrap dismiss in pcall for safety
              notification_id = nil -- Reset the ID
            end
            -- Show an error message
            noice.notify("Error processing request.", vim.log.levels.ERROR, {
              title = "CodeCompanion Error",
              name = "codecompanion", -- Associate with the plugin
            })
          end
        end,
      })

      require("codecompanion").setup({
        strategies = opts.strategies,
        adapters = opts.adapters,
      })
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
