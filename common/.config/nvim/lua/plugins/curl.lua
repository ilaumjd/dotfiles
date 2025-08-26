return {
  {
    "oysandvik94/curl.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("curl").setup {
        open_with = "buffer",
        mappings = {
          execute_curl = "<CR>",
        },
      }
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings
      -- normal mode mappings
      maps.n["<Leader>cc"] = {
        function() require("curl").create_global_collection() end,
        desc = "Create curl collection",
      }
      maps.n["<Leader>cf"] = {
        function() require("curl").pick_global_collection() end,
        desc = "Find curl collection",
      }
    end,
  },
}
