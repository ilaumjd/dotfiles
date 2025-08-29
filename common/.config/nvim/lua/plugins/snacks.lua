return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local get_icon = require("astroui").get_icon

      opts.dashboard = {
        preset = {
          header = table.concat({
            " █████  ███████ ████████ ██████   ██████ ",
            "██   ██ ██         ██    ██   ██ ██    ██",
            "███████ ███████    ██    ██████  ██    ██",
            "██   ██      ██    ██    ██   ██ ██    ██",
            "██   ██ ███████    ██    ██   ██  ██████ ",
            "",
            "███    ██ ██    ██ ██ ███    ███",
            "████   ██ ██    ██ ██ ████  ████",
            "██ ██  ██ ██    ██ ██ ██ ████ ██",
            "██  ██ ██  ██  ██  ██ ██  ██  ██",
            "██   ████   ████   ██ ██      ██",
          }, "\n"),
          keys = {
            { key = "n", action = "<Leader>n", icon = get_icon("FileNew", 0, true), desc = "New File  " },
            { key = "f", action = "<Leader>ff", icon = get_icon("Search", 0, true), desc = "Find File  " },
            { key = "o", action = "<Leader>fo", icon = "", desc = "Recent (cwd)  " },
            { key = "O", action = "<Leader>fO", icon = get_icon("DefaultFile", 0, true), desc = "Recents  " },
            { key = "w", action = "<Leader>fw", icon = get_icon("WordFile", 0, true), desc = "Find Word  " },
            { key = "'", action = "<Leader>f'", icon = get_icon("Bookmarks", 0, true), desc = "Bookmarks  " },
            { key = "s", action = "<Leader>Sl", icon = get_icon("Refresh", 0, true), desc = "Last Session  " },
            { key = "q", action = "<cmd>qa<CR>", icon = "󰩈", desc = "Quit" },
          },
        },
      }
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings
      local snack_opts = require("astrocore").plugin_opts "snacks.nvim"

      if vim.tbl_get(snack_opts, "picker", "enabled") ~= false then
        local Snacks = require "snacks"
        maps.n["gd"] = { function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" }
        maps.n["gD"] = { function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" }
        maps.n["grr"] = { function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" }
        maps.n["gri"] = { function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" }
        maps.n["grt"] = { function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" }
        maps.n["<Leader>fy"] = { function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" }
      end
    end,
  },
}
