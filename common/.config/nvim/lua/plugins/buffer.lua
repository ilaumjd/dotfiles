return {
  {
    "j-morano/buffer_manager.nvim",
    lazy = true,
    config = function() require("buffer_manager").setup {} end,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings
      maps.n["<Leader>bm"] = {
        function() require("buffer_manager.ui").toggle_quick_menu() end,
        desc = "Buffer manager",
      }
    end,
  },
}
