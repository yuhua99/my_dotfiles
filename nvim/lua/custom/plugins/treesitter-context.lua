-- Show context of the current function
return {
  'nvim-treesitter/nvim-treesitter-context',
  event = 'VeryLazy',
  opts = function()
    return { mode = 'cursor', max_lines = 3 }
  end,
}
