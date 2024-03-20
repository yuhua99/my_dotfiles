return {
  filter = function()
    if vim.bo.filetype == "vue" then
      return false
    elseif vim.bo.filetype == "go" then
      return false
    end

    return true
  end,
}
