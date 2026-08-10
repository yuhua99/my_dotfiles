-- Buffer close/restore helpers
local recently_closed = {}

local function track_current_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local bt = vim.bo[buf].buftype

  if name == '' or bt ~= '' then
    return
  end

  table.insert(recently_closed, {
    path = name,
    cursor = vim.api.nvim_win_get_cursor(0),
  })
end

local function close_buffer_and_track()
  track_current_buffer()
  vim.cmd 'BufDel'
end

local function restore_last_closed_buffer()
  local entry = table.remove(recently_closed)

  if not entry then
    vim.notify('No recently closed buffer to restore', vim.log.levels.INFO)
    return
  end

  vim.cmd.edit(vim.fn.fnameescape(entry.path))
  pcall(vim.api.nvim_win_set_cursor, 0, entry.cursor)
end

-- Conform (formatting)
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end

    return {
      timeout_ms = 800,
      lsp_format = 'fallback',
    }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    vue = { 'prettier' },
    json = { 'prettier' },
  },
  formatters = {
    prettier = {
      command = 'prettier',
      args = { '--stdin-filepath', '$FILENAME' },
      stdin = true,
    },
  },
}

-- Mini.nvim modules
require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()

local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
statusline.section_location = function()
  return '%2l:%-2v'
end

-- Indent blankline
require('ibl').setup {}
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function(args)
    if vim.b[args.buf].big_file then
      require('ibl').setup_buffer(args.buf, { enabled = false })
    end
  end,
})

-- Colorizer
require('colorizer').setup {
  user_default_options = {
    mode = 'virtualtext',
    virtualtext_inline = true,
  },
}
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function(args)
    if vim.b[args.buf].big_file then
      require('colorizer').detach_from_buffer(args.buf)
    end
  end,
})

-- Todo comments
require('todo-comments').setup { signs = false }

-- Autopairs
require('nvim-autopairs').setup {}

-- Which-key
require('which-key').setup {
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
    keys = vim.g.have_nerd_font and {} or {
      Up = '<Up> ',
      Down = '<Down> ',
      Left = '<Left> ',
      Right = '<Right> ',
      C = '<C-…> ',
      M = '<M-…> ',
      D = '<D-…> ',
      S = '<S-…> ',
      CR = '<CR> ',
      Esc = '<Esc> ',
      ScrollWheelDown = '<ScrollWheelDown> ',
      ScrollWheelUp = '<ScrollWheelUp> ',
      NL = '<NL> ',
      BS = '<BS> ',
      Space = '<Space> ',
      Tab = '<Tab> ',
      F1 = '<F1>',
      F2 = '<F2>',
      F3 = '<F3>',
      F4 = '<F4>',
      F5 = '<F5>',
      F6 = '<F6>',
      F7 = '<F7>',
      F8 = '<F8>',
      F9 = '<F9>',
      F10 = '<F10>',
      F11 = '<F11>',
      F12 = '<F12>',
    },
  },
  spec = {
    { '<leader>a', group = 'Ai' },
    { '<leader>b', group = 'Buffer' },
    { '<leader>c', group = 'Code' },
    { '<leader>f', group = 'Find' },
    { '<leader>g', group = 'Git' },
    { '<leader>p', group = 'Plugins' },
    { '<leader>s', group = 'Search' },
    { '<leader>t', group = 'Toggle' },
    { '<leader>u', group = 'Ui' },
  },
}

-- Flash
require('flash').setup {
  modes = {
    char = { enabled = false },
  },
}
vim.api.nvim_set_hl(0, 'FlashLabel', { link = 'Special' })

-- Treesitter (new main-branch API for Neovim 0.12+)
-- Highlighting is enabled automatically by Neovim for installed parsers.
-- Parser installation is handled by the PackChanged hook in init.lua (TSUpdate).
require('nvim-treesitter').setup {}

-- Gitsigns
require('gitsigns').setup {
  signs = {
    delete = { text = '󰍵' },
    changedelete = { text = '󱕖' },
  },
}

-- Fzf-lua
require('fzf-lua').setup {
  previewers = {
    builtin = {
      syntax_limit_b = 1024 * 100,
    },
  },
  grep = {
    rg_glob = true,
    rg_glob_fn = function(query)
      local regex, flags = query:match '^(.-)%s%-%-(.*)$'
      return regex or query, flags
    end,
  },
}
require('fzf-lua').register_ui_select()

-- Bufferline
require('bufferline').setup {
  options = {
    always_show_bufferline = false,
    custom_filter = function(buf_number)
      local buf_name = vim.fn.bufname(buf_number)
      local buf_ft = vim.fn.getbufvar(buf_number, '&filetype')
      if buf_ft == 'oil' or buf_ft == 'checkhealth' or string.match(buf_name, 'oil://') then
        return false
      end
      return true
    end,
  },
}

-- [[ Keymaps ]]

-- Bufferline / buffer management
vim.keymap.set('n', 'H', '<cmd>BufferLineCyclePrev<CR>')
vim.keymap.set('n', 'L', '<cmd>BufferLineCycleNext<CR>')
vim.keymap.set('n', '<leader>x', close_buffer_and_track, { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>bo', '<cmd>BufferLineCloseOthers<CR>', { desc = 'Close all other buffers' })
vim.keymap.set('n', '<leader>bx', close_buffer_and_track, { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>br', restore_last_closed_buffer, { desc = 'Restore recently closed buffer' })

-- Fzf-lua
vim.keymap.set('n', 'fw', '<cmd>FzfLua live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', 'ff', '<cmd>FzfLua files<CR>', { desc = 'Open file picker' })
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua resume<CR>', { desc = 'Resume' })
vim.keymap.set('n', '<leader>fs', '<cmd>FzfLua grep_cword<CR>', { desc = 'Search word under cursor' })
vim.keymap.set('n', '<leader>fw', '<cmd>FzfLua live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<CR>', { desc = 'Open file picker' })
vim.keymap.set('n', '<leader>fW', function()
  require('fzf-lua').live_grep { rg_opts = '-n --column --no-ignore' }
end, { desc = 'Live grep (no-ignore)' })
vim.keymap.set('n', '<leader>fF', function()
  require('fzf-lua').files { fd_opts = '--type f --hidden --follow --exclude .git --no-ignore' }
end, { desc = 'Files (no-ignore)' })
vim.keymap.set('n', '<leader>gs', '<cmd>FzfLua git_status<CR>', { desc = 'Git status' })
vim.keymap.set('n', '<leader>gc', '<cmd>FzfLua git_commits<CR>', { desc = 'Git commits' })
vim.keymap.set('n', '<leader>cR', '<cmd>FzfLua lsp_references<CR>', { desc = 'Fzf references' })
vim.keymap.set('n', '<leader>cD', '<cmd>FzfLua lsp_definitions<CR>', { desc = 'Fzf definitions' })
vim.keymap.set('n', '<leader>cs', '<cmd>FzfLua lsp_document_symbols<CR>', { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua helptags<CR>', { desc = 'Help tags' })
vim.keymap.set('n', '<leader>gf', '<cmd>FzfLua git_files<CR>', { desc = 'Git files' })
vim.keymap.set('n', 'gd', '<cmd>FzfLua lsp_definitions<CR>', { desc = 'Go to definition' })
vim.keymap.set('n', 'gR', '<cmd>FzfLua lsp_references<CR>', { desc = 'Go to references' })
vim.keymap.set('n', 'gi', '<cmd>FzfLua lsp_implementations<CR>', { desc = 'Go to implementation' })

-- Flash
vim.keymap.set({ 'n', 'x', 'o' }, 'f', '<Nop>', { desc = 'Disabled' })
vim.keymap.set({ 'n', 'x', 'o' }, 'fl', function()
  require('flash').jump()
end, { desc = 'Flash' })
vim.keymap.set({ 'n', 'x', 'o' }, 'fL', function()
  require('flash').treesitter()
end, { desc = 'Flash Treesitter' })

-- Gitsigns
vim.keymap.set('n', ']h', function()
  if vim.wo.diff then
    vim.cmd.normal { ']h', bang = true }
  else
    require('gitsigns').nav_hunk 'next'
  end
end, { desc = 'Git next hunk' })

vim.keymap.set('n', '[h', function()
  if vim.wo.diff then
    vim.cmd.normal { '[h', bang = true }
  else
    require('gitsigns').nav_hunk 'prev'
  end
end, { desc = 'Git prev hunk' })

vim.keymap.set({ 'n', 'v' }, '<leader>gr', function()
  local gs = require 'gitsigns'
  local mode = vim.fn.mode()
  if mode:match '[vV\22]' then
    local l1 = vim.fn.line '.'
    local l2 = vim.fn.line 'v'
    gs.reset_hunk { math.min(l1, l2), math.max(l1, l2) }
  else
    gs.reset_hunk()
  end
end, { desc = 'Git restore hunk' })

vim.keymap.set({ 'n', 'v' }, '<leader>ga', function()
  local gs = require 'gitsigns'
  local mode = vim.fn.mode()
  if mode:match '[vV\22]' then
    local l1 = vim.fn.line '.'
    local l2 = vim.fn.line 'v'
    gs.stage_hunk { math.min(l1, l2), math.max(l1, l2) }
  else
    gs.stage_hunk()
  end
end, { desc = 'Git stage/unstage hunk' })

vim.keymap.set('n', '<leader>gb', function()
  require('gitsigns').blame_line { full = true }
end, { desc = 'Git blame line' })

-- Conform
vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = 'Format' })
