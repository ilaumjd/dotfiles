return {
  "piersolenski/wtf.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {},
  keys = {
    {
      "<leader>xa",
      mode = { "n", "x" },
      function()
        require("wtf").ai()
      end,
      desc = "Explain with AI",
    },
    {
      mode = { "n" },
      "<leader>xs",
      function()
        require("wtf").search()
      end,
      desc = "Search",
    },
  },
}
