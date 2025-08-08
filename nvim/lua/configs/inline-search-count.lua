-- lua/config/inline_search_count.lua
local M = {}

function M.setup()
  local ns = vim.api.nvim_create_namespace "inline_search_count"
  local function clear(buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end

  local function show()
    local buf = vim.api.nvim_get_current_buf()
    clear(buf)
    if vim.v.hlsearch == 0 then
      return
    end
    local pat = vim.fn.getreg "/"
    if not pat or pat == "" then
      return
    end

    local sc = vim.fn.searchcount { recompute = 1, maxcount = 1000 }
    if sc.total == 0 then
      return
    end

    local start = vim.fn.searchpos(pat, "cn")
    if start[1] == 0 then
      return
    end
    local endpos = vim.fn.searchpos(pat, "cne")

    local sp = vim.fn.screenpos(0, start[1], endpos[2])
    if sp.col == 0 then
      return
    end

    local label = string.format("[%d/%s]", sc.current, sc.total > 999 and ">999" or sc.total)
    vim.api.nvim_buf_set_extmark(buf, ns, start[1] - 1, 0, {
      virt_text = { { label, "InlineSearchCount" } },
      virt_text_win_col = sp.col, -- add +1 for a space after the match
      priority = 5000,
    })
  end

  vim.api.nvim_create_autocmd({ "CursorMoved", "CmdlineLeave" }, {
    group = vim.api.nvim_create_augroup("InlineSearchCount", { clear = true }),
    callback = function()
      vim.schedule(show)
    end,
  })

  vim.api.nvim_set_hl(0, "InlineSearchCount", { link = "Search" })

  -- Optional: refresh after jumping between matches
  for _, k in ipairs { "n", "N", "*", "#", "g*", "g#" } do
    vim.keymap.set("n", k, function()
      vim.cmd.normal { args = { vim.v.count1 .. k }, bang = true }
      show()
    end, { silent = true })
  end
end

return M
