return {
  'ojroques/nvim-osc52',
  config = function()
    local loaded, osc52 = pcall(require, 'osc52')
    if not loaded then
      vim.notify('nvim-osc52 failed to load', vim.log.levels.WARN)
      return
    end

    osc52.setup({
      trim = false, -- keep trailing newlines intact; clipboard can handle it
      max_length = 0, -- do not truncate yanks
    })

    local function copy(lines, _)
      osc52.copy(table.concat(lines, '\n'))
    end

    local function paste()
      local reg = vim.fn.getreg('"')
      return { vim.split(reg, '\n'), vim.fn.getregtype('"') }
    end

    vim.g.clipboard = {
      name = 'osc52',
      copy = { ['+'] = copy, ['*'] = copy },
      paste = { ['+'] = paste, ['*'] = paste },
    }

    vim.api.nvim_create_autocmd('TextYankPost', {
      callback = function()
        if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
          osc52.copy_register('"')
        end
      end,
    })
  end,
}
