local mapping_key_prefix = '<leader>a'

return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    build = ':Copilot auth',
    event = 'BufReadPost',
    config = function()
      require('copilot').setup {
        suggestion = { enable = false },
        panel = { enable = false },
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    main = 'nvim-treesitter.config',
    opts = { ensure_installed = { 'yaml', 'markdown' } },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
    opts = {
      render_modes = true, -- Render in ALL modes
      sign = {
        enabled = false, -- Turn off in the status column
      },
      latex = {
        enabled = false, -- Disable LaTeX rendering
      },
      completions = { blink = { enabled = true } },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'MeanderingProgrammer/render-markdown.nvim', -- Make Markdown buffers look beautiful
    },
    opts = {
      adapters = {
        http = {
          copilot = function()
            return require('codecompanion.adapters').extend('copilot', {
              schema = {
                model = {
                  default = 'claude-sonnet-4.6',
                },
              },
            })
          end,
        },
      },
      strategies = {
        chat = {
          adapter = 'copilot',
          roles = {
            llm = function(adapter)
              local model_name = ''
              if adapter.schema and adapter.schema.model and adapter.schema.model.default then
                local model = adapter.schema.model.default
                if type(model) == 'function' then
                  model = model(adapter)
                end
                model_name = '(' .. model .. ')'
              end
              return '  ' .. adapter.formatted_name .. model_name
            end,
            user = ' User',
          },
          slash_commands = {
            ['buffer'] = {
              callback = 'strategies.chat.slash_commands.buffer',
              description = 'Insert open buffers',
              opts = {
                contains_code = true,
                provider = 'fzf_lua', -- default|telescope|mini_pick|fzf_lua
              },
            },
            ['file'] = {
              callback = 'strategies.chat.slash_commands.file',
              description = 'Insert a file',
              opts = {
                contains_code = true,
                max_lines = 1000,
                provider = 'fzf_lua', -- telescope|mini_pick|fzf_lua
              },
            },
          },
          keymaps = {
            send = {
              callback = function(chat)
                vim.cmd 'stopinsert'
                chat:submit()
                chat:add_buf_message { role = 'llm', content = '' }
              end,
              index = 1,
              description = 'Send',
            },
            toggle = {
              modes = {
                n = 'q',
              },
              index = 3,
              callback = function()
                vim.cmd 'CodeCompanionChat Toggle'
              end,
              description = 'Toggle Chat',
            },
            close = {
              modes = {
                n = 'Q',
              },
              index = 3,
              callback = 'keymaps.close',
              description = 'Close Chat',
            },
            stop = {
              modes = {
                n = '<C-c>',
              },
              index = 4,
              callback = 'keymaps.stop',
              description = 'Stop Request',
            },
          },
        },
        inline = { adapter = 'copilot' },
        agent = { adapter = 'copilot' },
      },
      inline = {
        layout = 'buffer', -- vertical|horizontal|buffer
      },
      display = {
        chat = {
          -- Change to true to show the current model
          show_settings = false,
          window = {
            layout = 'vertical', -- float|vertical|horizontal|buffer
            width = 0.3,
          },
        },
      },
    },
    keys = {
      -- Recommend setup
      {
        mapping_key_prefix .. 'p',
        '<cmd>CodeCompanionActions<cr>',
        desc = 'Prompt Actions',
      },
      {
        mapping_key_prefix .. 'a',
        function()
          vim.cmd 'CodeCompanionChat Toggle'
          vim.cmd 'startinsert'
        end,
        desc = 'Toggle',
        mode = { 'n', 'v' },
      },
      -- Some common usages with visual mode
      {
        mapping_key_prefix .. 'l',
        '<cmd>CodeCompanion /lsp<cr>',
        desc = 'Explain LSP diagnostic',
        mode = { 'n', 'v' },
      },
      {
        mapping_key_prefix .. 'm',
        '<cmd>CodeCompanion /commit<cr>',
        desc = 'Git commit message',
      },
      -- Custom prompts
      {
        mapping_key_prefix .. 'M',
        '<cmd>CodeCompanion /staged-commit<cr>',
        desc = 'Git commit message (staged)',
      },
      -- Quick chat
      {
        mapping_key_prefix .. 'q',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            vim.cmd('CodeCompanion ' .. input)
          end
        end,
        desc = 'Quick chat',
      },
    },
    config = function(_, opts)
      local spinner = require 'plugins.code-companion.spinner'
      spinner:init()

      -- Setup the entire opts table
      require('codecompanion').setup(opts)
    end,
  },
}
