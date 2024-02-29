return {
  filter = function()
    if vim.bo.filetype == "vue" then
      return false
    end

    return true
  end,
}
