return {
  "olimorris/persisted.nvim",
  config = function()
    require("persisted").setup({
      should_save = function()
        if vim.bo.filetype == "startup" then
          return false
        end
        return true
      end,
    })
  end,
}
