return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format",
    },
  },
  opts = {
    formatters_by_ft = {
      c = { "clang_format" },
      go = { "gofmt" },
      kdl = { "kdlfmt" },
      lua = { "stylua" },
      nix = { "nixfmt" },
      python = { "ruff_format" },
      eruby = { "erb_format" },
      ruby = { "rubocop" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      sql = { "sql_formatter" },
      swift = { "swiftformat" },
      toml = { "taplo" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescriptreact = { "prettierd" },
      json = { "prettierd" },
      jsonc = { "prettierd" },
      html = { "prettierd" },
      css = { "prettierd" },
      yaml = { "prettierd" },
    },
    format_on_save = {
      timeout_ms = 2500,
      lsp_fallback = true,
    },
    formatters = {
      kdlfmt = {
        command = "kdlfmt",
        args = { "format", "-" },
        stdin = true,
      },
      sql_formatter = {
        inherit = false,
        command = "sql-formatter",
        args = { "-l", "postgresql" },
      },
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
