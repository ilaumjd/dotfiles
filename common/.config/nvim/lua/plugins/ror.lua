return {
  {
    "weizheheng/ror.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      { "rcarriga/nvim-notify", optional = true },
      { "stevearc/dressing.nvim", optional = true },
    },
    config = function()
      require("ror").setup {
        -- you can customize options here; defaults are fine otherwise
        test = {
          message = {
            file = "Running test file...",
            line = "Running single test...",
          },
          coverage = {
            up = "DiffAdd",
            down = "DiffDelete",
          },
          notification = {
            timeout = false,
          },
          pass_icon = "✅",
          fail_icon = "❌",
        },
      }

      -- Example of binding the list_commands helper to <leader>rc
      vim.keymap.set(
        "n",
        "<Leader>ur",
        function() require("ror.commands").list_commands() end,
        { silent = true, desc = "RoR Menu (ror.nvim)" }
      )
    end,
  },
}
