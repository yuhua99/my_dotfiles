require('auto-session').setup {
  suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
}

require('oil').setup {
  use_default_keymaps = false,
  keymaps = {
    ['?'] = { 'actions.show_help', mode = 'n' },
    ['<CR>'] = 'actions.select',
    ['<C-p>'] = 'actions.preview',
    ['q'] = { 'actions.close', mode = 'n' },
    ['<C-r>'] = 'actions.refresh',
    ['<BS>'] = { 'actions.parent', mode = 'n' },
    ['_'] = { 'actions.open_cwd', mode = 'n' },
    ['`'] = { 'actions.cd', mode = 'n' },
    ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
    ['gs'] = { 'actions.change_sort', mode = 'n' },
    ['gx'] = 'actions.open_external',
    ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
    ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
  },
}

do
  local osc52 = require 'osc52'
  osc52.setup {
    trim = false,
    max_length = 0,
  }

  local function copy(lines, _)
    osc52.copy(table.concat(lines, '\n'))
  end

  local function paste()
    local reg = vim.fn.getreg '"'
    return { vim.split(reg, '\n'), vim.fn.getregtype '"' }
  end

  vim.g.clipboard = {
    name = 'osc52',
    copy = { ['+'] = copy, ['*'] = copy },
    paste = { ['+'] = paste, ['*'] = paste },
  }

  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
        osc52.copy_register '"'
      end
    end,
  })
end
