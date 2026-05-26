return {

  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = function(_, opts)
  --     opts.servers = opts.servers or {}
  --     opts.servers.sourcekit = {
  --       root_dir = function(filename, _)
  --         local util = require("lspconfig.util")
  --         return util.root_pattern("buildServer.json")(filename)
  --           or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
  --           or util.find_git_ancestor(filename)
  --           or util.root_pattern("Package.swift")(filename)
  --       end,
  --     }
  --     require("lspconfig").sourcekit.setup(opts.servers.sourcekit)
  --     return opts
  --   end,
  -- },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },

  -- {
  --   "wojciech-kulik/xcodebuild.nvim",
  --   dependencies = {
  --     "nvim-telescope/telescope.nvim",
  --     "MunifTanjim/nui.nvim",
  --   },
  --   config = function()
  --     require("xcodebuild").setup({
  --       code_coverage = {
  --         enabled = true,
  --       },
  --     })
  --
  --     vim.keymap.set("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Toggle Xcodebuild Logs" })
  --     vim.keymap.set("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>", { desc = "Build Project" })
  --     vim.keymap.set("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", { desc = "Build & Run Project" })
  --     vim.keymap.set("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
  --     vim.keymap.set("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", { desc = "Run This Test Class" })
  --     vim.keymap.set("n", "<leader>X", "<cmd>XcodebuildPicker<cr>", { desc = "Show All Xcodebuild Actions" })
  --     vim.keymap.set("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", { desc = "Select Device" })
  --     vim.keymap.set("n", "<leader>xp", "<cmd>XcodebuildSelectTestPlan<cr>", { desc = "Select Test Plan" })
  --     vim.keymap.set("n", "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", { desc = "Toggle Code Coverage" })
  --     vim.keymap.set(
  --       "n",
  --       "<leader>xC",
  --       "<cmd>XcodebuildShowCodeCoverageReport<cr>",
  --       { desc = "Show Code Coverage Report" }
  --     )
  --     vim.keymap.set("n", "<leader>xq", "<cmd>Telescope quickfix<cr>", { desc = "Show QuickFix List" })
  --   end,
  -- },
}
