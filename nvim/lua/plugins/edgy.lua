return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  opts = {
    right = {
      -- Claude Code terminal window
      {
        ft = "terminal",
        size = { width = 0.3 },
        filter = function(buf, win)
          -- Only capture Claude Code terminals
          local buf_name = vim.api.nvim_buf_get_name(buf)
          return buf_name:match("claude")
            or buf_name:match("Claude")
            or (vim.bo[buf].buftype == "terminal" and buf_name:match("term://.*claude"))
        end,
        title = "Claude Code",
      },
    },
  },
  init = function()
    -- Automatically exclude Claude Code terminals from buffer list
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*",
      callback = function(args)
        local buf = args.buf
        local buf_name = vim.api.nvim_buf_get_name(buf)

        -- Check if this is a Claude Code terminal
        if buf_name:match("claude") or buf_name:match("Claude") then
          -- Exclude from buffer list
          vim.bo[buf].buflisted = false
          vim.bo[buf].bufhidden = "wipe"
        end
      end,
    })
  end,
}