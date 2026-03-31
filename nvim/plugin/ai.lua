local mapping_key_prefix = '<leader>a'

require('copilot').setup {
  suggestion = { enable = false },
  panel = { enable = false },
}

-- Sidekick: lazy-loaded on first keymap use
local sidekick_loaded = false
local function ensure_sidekick()
  if sidekick_loaded then
    return true
  end

  vim.pack.add { 'https://github.com/folke/sidekick.nvim' }
  require('sidekick').setup {
    cli = {
      win = {
        keys = {
          nav_left = { '<M-h>', 'nav_left', expr = true, desc = 'Go to left window' },
          nav_right = { '<M-l>', 'nav_right', expr = true, desc = 'Go to right window' },
        },
      },
    },
  }
  sidekick_loaded = true

  return true
end

vim.keymap.set('n', mapping_key_prefix .. 'a', function()
  if ensure_sidekick() then
    require('sidekick.cli').toggle()
  end
end, { desc = 'Sidekick Toggle CLI' })

vim.keymap.set('n', mapping_key_prefix .. 's', function()
  if ensure_sidekick() then
    require('sidekick.cli').select()
  end
end, { desc = 'Sidekick Select CLI' })

vim.keymap.set({ 'n', 'x' }, mapping_key_prefix .. 'p', function()
  if ensure_sidekick() then
    require('sidekick.cli').prompt()
  end
end, { desc = 'Sidekick Prompt' })

vim.keymap.set('n', mapping_key_prefix .. 'c', function()
  if ensure_sidekick() then
    require('sidekick.cli').toggle { name = 'codex', focus = true }
  end
end, { desc = 'Sidekick Codex' })

vim.keymap.set('n', mapping_key_prefix .. 'o', function()
  if ensure_sidekick() then
    require('sidekick.cli').toggle { name = 'opencode', focus = true }
  end
end, { desc = 'Sidekick OpenCode' })

vim.keymap.set('n', mapping_key_prefix .. 'f', function()
  if ensure_sidekick() then
    require('sidekick.cli').send { msg = '{file}' }
  end
end, { desc = 'Sidekick Send File' })

vim.keymap.set('x', mapping_key_prefix .. 'v', function()
  if ensure_sidekick() then
    require('sidekick.cli').send { msg = '{selection}' }
  end
end, { desc = 'Sidekick Send Selection' })
