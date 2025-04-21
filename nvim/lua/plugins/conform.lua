return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      fish = { "fish_indent" },
      sh = { "shfmt" },
      vue = { "prettier" },
      typescript = { "prettier" },
      json = { "prettier" },
    },
    formatters = {
      prettier = { -- Ensure Prettier uses project's .prettierrc
        command = "prettier",
        args = { "--stdin-filepath", "$FILENAME" },
        stdin = true,
      },
    },
  },
}
