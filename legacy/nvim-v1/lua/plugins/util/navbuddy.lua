return {
  "SmiteshP/nvim-navbuddy",
  dependencies = {
    "neovim/nvim-lspconfig",
    "SmiteshP/nvim-navic",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local navbuddy = require("nvim-navbuddy")

    navbuddy.setup({
      use_default_mappings = true,
      lsp = {
        auto_attach = true,
        preference = nil,
      },
      icons = {
        File = "󰈙 ",
        Module = " ",
        Namespace = "󰌗 ",
        Package = " ",
        Class = "󰌗 ",
        Method = "󰆧 ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = "󰕘 ",
        Interface = "󰕘 ",
        Function = "󰊕 ",
        Variable = "󰆧 ",
        Constant = "󰏿 ",
        String = " ",
        Number = "󰎠 ",
        Boolean = "◩ ",
        Array = "󰅪 ",
        Object = "󰅩 ",
        Key = "󰌋 ",
        Null = "󰟢 ",
        EnumMember = " ",
        Struct = "󰌗 ",
        Event = " ",
        Operator = "󰆕 ",
        TypeParameter = "󰊄 ",
      },
      node_markers = {
        enabled = true,
        icons = {
          leaf = "  ",
          leaf_selected = " → ",
          branch = " ",
        },
      },
    })

    vim.keymap.set("n", "<leader>cn", navbuddy.open, { desc = "Open Navbuddy" })
  end,
}
