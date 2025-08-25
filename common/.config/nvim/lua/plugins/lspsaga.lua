return {
  {
    "nvimdev/lspsaga.nvim",
    opts = function(_, opts)
      -- override defaults safely
      opts = vim.tbl_deep_extend("force", opts or {}, {
        keymaps = {
          -- You can also configure lspsaga’s internal keymaps here if you want
        },
      })
      return opts
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings

      -- remove default LSP mappings first if you want clean replacement
      maps.n["grr"] = false
      maps.n["gra"] = false
      maps.v["gra"] = false
      maps.n["grn"] = false
      maps.n["gri"] = false
      maps.n["grt"] = false
      maps.n["gO"] = false
      maps.i["<C-s>"] = false

      -- now add Lspsaga mappings
      maps.n["grr"] = { "<cmd>Lspsaga finder<CR>", desc = "References (Lspsaga)" }
      maps.n["gra"] = { "<cmd>Lspsaga code_action<CR>", desc = "Code Action (Lspsaga)" }
      maps.v["gra"] = { "<cmd>Lspsaga code_action<CR>", desc = "Code Action (Lspsaga)" }
      maps.n["grn"] = { "<cmd>Lspsaga rename<CR>", desc = "Rename (Lspsaga)" }
      maps.n["gri"] = { "<cmd>Lspsaga implement<CR>", desc = "Implementation (Lspsaga)" }
      maps.n["grt"] = { "<cmd>Lspsaga goto_type_definition<CR>", desc = "Type Definition (Lspsaga)" }
      maps.n["gO"] = { "<cmd>Lspsaga outline<CR>", desc = "Document Symbols (Outline)" }
      maps.i["<C-s>"] = { "<cmd>Lspsaga signature_help<CR>", desc = "Signature Help (Lspsaga)" }
    end,
  },
}
