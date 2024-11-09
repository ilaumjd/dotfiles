return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      -- lspkind
      "onsails/lspkind.nvim",
      -- snippets
      "L3MON4D3/LuaSnip",
      -- codeium
      "Exafunction/codeium.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            show_labelDetails = true,
            preset = "codicons",
            symbol_map = { Codeium = "󰘦" },
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "path", priority = 2 },
          { name = "buffer", priority = 1, keyword_length = 3 },
          { name = "codeium", priority = 0 },
        }),
        enabled = function()
          local disabled_filetypes = {
            "oil",
            "buffer_manager",
          }

          local filetype = vim.api.nvim_buf_get_option(0, "filetype")
          return not vim.tbl_contains(disabled_filetypes, filetype)
        end,
      })
    end,
  },
}
