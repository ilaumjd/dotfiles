return {
  "gbprod/substitute.nvim",
  config = function()
    local substitute = require("substitute")

    substitute.setup()

    local map = vim.keymap.set
    map("n", "s", substitute.operator, {
      noremap = true,
      desc = "Substitute operator (use with motion)",
    })
    map("n", "ss", substitute.line, {
      noremap = true,
      desc = "Substitute entire line",
    })
    map("n", "S", substitute.eol, {
      noremap = true,
      desc = "Substitute to end of line",
    })
    map("x", "s", substitute.visual, {
      noremap = true,
      desc = "Substitute visual selection",
    })
  end,
}
