return {
  "j-morano/buffer_manager.nvim",
  config = function()
    require("buffer_manager").setup({})
  end,
  keys = {
    { "J", "<Cmd>lua require('buffer_manager.ui').toggle_quick_menu()<CR>", desc = "Open bufferlist" },
    { "H", "<Cmd>lua require('buffer_manager.ui').nav_prev()<CR>", desc = "Open bufferlist" },
    { "L", "<Cmd>lua require('buffer_manager.ui').nav_next()<CR>", desc = "Open bufferlist" },
  },
}
