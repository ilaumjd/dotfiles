return {
  {
    "gbprod/substitute.nvim",
    opts = {}, -- use defaults
    keys = {
      {
        "s",
        function() require("substitute").operator() end,
        mode = "n",
        desc = "Substitute operator (use with motion)",
      },
      {
        "ss",
        function() require("substitute").line() end,
        mode = "n",
        desc = "Substitute entire line",
      },
      {
        "S",
        function() require("substitute").eol() end,
        mode = "n",
        desc = "Substitute to end of line",
      },
      {
        "s",
        function() require("substitute").visual() end,
        mode = "x",
        desc = "Substitute visual selection",
      },
    },
  },
}
