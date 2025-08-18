return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  -- {
  --   "williamboman/mason-lspconfig.nvim",
  --   config = function()
  --     require("mason-lspconfig").setup({
  --       ensure_installed = {
  --         -- c
  --         "clangd",
  --         -- go
  --         "gopls",
  --         -- javascript
  --         "eslint",
  --         "ts_ls",
  --         -- lua
  --         "lua_ls",
  --         -- nix
  --         "nil_ls",
  --         -- ruby
  --         "rubocop",
  --         "solargraph",
  --         -- rust
  --         "rust_analyzer",
  --       },
  --       automatic_installation = true,
  --     })
  --   end,
  -- },
  -- {
  --   "zapling/mason-conform.nvim",
  --   config = function()
  --     require("mason-conform").setup({})
  --   end,
  -- },
}
