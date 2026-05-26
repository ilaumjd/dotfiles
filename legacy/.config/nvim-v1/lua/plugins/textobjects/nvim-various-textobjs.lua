return {
  "chrisgrieser/nvim-various-textobjs",
  config = function()
    require("various-textobjs").setup({
      keymap = {
        useDefault = true,
      },
    })
  end,
}
