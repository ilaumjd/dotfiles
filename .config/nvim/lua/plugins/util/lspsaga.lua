return {
  "nvimdev/lspsaga.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    { "nvim-treesitter/nvim-treesitter" },
  },
  event = "LspAttach",
  config = function()
    require("lspsaga").setup({
      symbol_in_winbar = {
        enable = true,
      },
      lightbulb = {
        enable = false,
      },
    })

    local map = vim.keymap.set

    -- Peek
    map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover Documentation" })

    -- Go to
    map("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "Go to Definition" })
    map("n", "gy", "<cmd>Lspsaga goto_type_definition<CR>", { desc = "Go to Type Definition" })
    map("n", "gr", "<cmd>Lspsaga finder<CR>", { desc = "LSP Finder" })

    -- Code
    map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code Action" })
    map("n", "<leader>cm", "<cmd>Lspsaga outline<CR>", { desc = "Code Outline" })
    map("n", "<leader>cb", "<cmd>Lspsaga winbar_toggle<CR>", { desc = "Toggle Winbar" })
    map("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", { desc = "Incoming Calls" })
    map("n", "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>", { desc = "Outgoing Calls" })

    -- Diagnostics
    map("n", "<leader>xd", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Line Diagnostics" })
    map("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Previous Diagnostic" })
    map("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next Diagnostic" })
  end,
}
