require('mason').setup {}
require('fidget').setup {}

require('luasnip').setup {}
require('luasnip.loaders.from_vscode').lazy_load()

require('blink.cmp').setup {
  keymap = {
    preset = 'none',
    ['<Tab>'] = {
      'snippet_forward',
      function()
        local ok, sidekick = pcall(require, 'sidekick')
        if ok then
          return sidekick.nes_jump_or_apply()
        end
      end,
      function()
        return vim.lsp.inline_completion.get()
      end,
      'select_next',
      'fallback',
    },
    ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'hide', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'copilot' },
    providers = {
      copilot = {
        module = 'blink-cmp-copilot',
        name = 'copilot',
        score_offset = 100,
        async = true,
      },
    },
  },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  signature = { enabled = true },
}

-- LSP attach keymaps and behavior
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    if vim.b[event.buf].big_file then
      vim.lsp.buf_detach_client(event.buf, event.data.client_id)
      return
    end

    local map = function(keys, func, desc, mode, opts)
      mode = mode or 'n'
      opts = opts or {}
      local options = vim.tbl_extend('force', { buffer = event.buf, desc = 'LSP: ' .. desc }, opts)
      vim.keymap.set(mode, keys, func, options)
    end

    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('gt', vim.lsp.buf.type_definition, 'Go to type definition')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'v' })
    map('<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
    map('[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
    map(']d', vim.diagnostic.goto_next, 'Next diagnostic')
    map('<leader>ce', vim.diagnostic.open_float, 'Show diagnostic')
    map('<leader>cy', function()
      local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
      local diags = vim.diagnostic.get(event.buf, { lnum = lnum })

      if #diags == 0 then
        vim.notify('No diagnostic on this line')
        return
      end

      vim.fn.setreg('+', diags[1].message)
      vim.notify('Diagnostic yanked')
    end, 'Yank diagnostic')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>ch', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, 'Toggle inlay hints')
    end
  end,
})

-- Diagnostics
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

-- LSP server configs
local capabilities = require('blink.cmp').get_lsp_capabilities()

local vue_ls_path = vim.fn.expand '$MASON/packages/vue-language-server'
local vue_plugin_path = vue_ls_path .. '/node_modules/@vue/language-server'
local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_plugin_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}

vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
    },
  },
})
vim.lsp.config('ts_ls', {
  capabilities = capabilities,
  init_options = {
    plugins = {
      vue_plugin,
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})
vim.lsp.config('rust_analyzer', { capabilities = capabilities })
vim.lsp.config('gopls', { capabilities = capabilities })
vim.lsp.config('ruff', { capabilities = capabilities })
vim.lsp.config('ty', { capabilities = capabilities })
vim.lsp.config('copilot', { capabilities = capabilities })

vim.lsp.enable {
  'lua_ls',
  'ts_ls',
  'rust_analyzer',
  'gopls',
  'ruff',
  'ty',
  'copilot',
}
