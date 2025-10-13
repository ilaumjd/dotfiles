local is_xcode_project = function()
  local cwd = vim.fn.getcwd()
  local has_xcodeproj = vim.fn.glob(cwd .. "/*.xcodeproj") ~= ""
  local has_xcworkspace = vim.fn.glob(cwd .. "/*.xcworkspace") ~= ""
  return has_xcodeproj or has_xcworkspace
end

return {
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local null_ls = require "null-ls"
      opts.sources = require("astrocore").list_insert_unique(opts.sources, {
        null_ls.builtins.formatting.swiftformat,
        null_ls.builtins.formatting.swiftlint,
        null_ls.builtins.diagnostics.swiftlint,
      })
    end,
  },
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.config = opts.config or {}
      opts.config.sourcekit = {
        on_attach = function(client, _)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      }
      return opts
    end,
  },
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "MunifTanjim/nui.nvim",
      "stevearc/oil.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    cond = is_xcode_project,
    config = function()
      require("xcodebuild").setup {
        integrations = {
          xcodebuild_offline = {
            enabled = true,
          },
          pymobiledevice = {
            enabled = true,
          },
        },
      }

      require("xcodebuild.integrations.dap").setup(os.getenv "HOME" .. "/bin/codelldb/extension/adapter/codelldb")
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      if not is_xcode_project() then return opts end

      local maps = opts.mappings
      maps.n["<Leader>x"] = { nil, desc = "Xcodebuild" }
      maps.n["<Leader>xb"] = { "<Cmd>XcodebuildBuild<CR>", desc = "Build" }
      maps.n["<Leader>xd"] = { "<Cmd>XcodebuildBuildDebug<CR>", desc = "Build and Debug" }
      maps.n["<Leader>xr"] = { "<Cmd>XcodebuildBuildRun<CR>", desc = "Build and Run" }
      maps.n["<Leader>xp"] = { "<Cmd>XcodebuildPicker<CR>", desc = "Picker" }
      maps.n["<Leader>xf"] = { "<Cmd>XcodebuildProjectManager<CR>", desc = "Project Manager" }
      maps.n["<Leader>xl"] = { "<Cmd>XcodebuildToggleLogs<CR>", desc = "Toggle Logs" }
      maps.n["<Leader>xc"] = { "<Cmd>XcodebuildCancel<CR>", desc = "Cancel" }
      maps.n["<Leader>xs"] = { "<Cmd>XcodebuildSetup<CR>", desc = "Setup" }
      maps.n["gra"] = { "<Cmd>XcodebuildCodeActions<CR>", desc = "Code Actions" }
      return opts
    end,
  },
}
