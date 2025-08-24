return {
  {
    "stevearc/oil.nvim",
    opts = function(_, opts)
      return require("astrocore").extend_tbl(opts, {
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        keymaps = {
          ["q"] = "actions.close",
        },
      })
    end,
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          -- remove the community’s <Leader>O mapping
          opts.mappings.n["<Leader>O"] = false
          -- add your own mapping: "-" to open Oil
          opts.mappings.n["-"] = {
            function() require("oil").open() end,
            desc = "Open Oil",
          }
        end,
      },
    },
  },
}
