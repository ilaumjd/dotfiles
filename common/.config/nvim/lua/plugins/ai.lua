return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false,
  opts = {
    mappings = {
      submit = {
        insert = "<C-a>",
      },
    },
  },
  build = "make",
  keys = {
    { "<leader>apc", "<cmd>AvanteSwitchProvider claude<CR>", desc = "avante: claude" },
    { "<leader>apo", "<cmd>AvanteSwitchProvider openai<CR>", desc = "avante: openai" },
  },
}
