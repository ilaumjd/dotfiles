return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      rust = { "rustfmt" },
      nix = { "nixfmt" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      jsx = { "prettier" },
      tsx = { "prettier" },
      json = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      yaml = { "prettier" },
      swift = { "swiftformat" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
