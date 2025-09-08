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
      maps.n["<Leader>cn"] = {
        function() require("curl").create_global_collection() end,
        desc = "Curl: New collection",
      }
      maps.n["<Leader>cf"] = {
        function() require("curl").pick_global_collection() end,
        desc = "Curl: Find collection",
      }
    end,
  },
}
