-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    treesitter = {
      auto_install = true,
    },
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    filetypes = {
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    options = {
      opt = {
        number = true,
        relativenumber = false,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        clipboard = "unnamedplus",
        completeopt = "menu,menuone,noselect",
        expandtab = true,
        mouse = "a",
        shiftwidth = 2,
        ignorecase = true,
        smartcase = true,
        smartindent = true,
        splitbelow = true,
        splitright = true,
        tabstop = 2,
        termguicolors = true,
        timeoutlen = 300,
        undofile = true,
        cursorline = true,
        linebreak = true,
        scrolloff = 5,
        sidescrolloff = 8,
        winborder = "none",
      },
      g = {},
    },
    mappings = {
      n = {
        ["<Leader>c"] = false,
        ["<Leader>C"] = false,
        ["[b"] = false,
        ["]b"] = false,
        ["<Leader>xq"] = false,
        ["<Leader>xl"] = false,

        ["H"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["L"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },

        ["x"] = { '"_x', desc = "Delete character without copying to register" },

        ["<Leader>uq"] = {
          function()
            vim.g._macro_enabled = not vim.g._macro_enabled
            if vim.g._macro_enabled then
              vim.cmd "unmap q"
              vim.notify "Macro recording enabled"
            else
              vim.cmd "map q <Nop>"
              vim.notify "Macro recording disabled"
            end
          end,
          desc = "Toggle macro recording",
        },
      },

      x = {
        ["H"] = { "<gv", desc = "Decrease indent tab" },
        ["J"] = { ":move '>+1<CR>gv-gv", desc = "Move selected text down" },
        ["K"] = { ":move '<-2<CR>gv-gv", desc = "Move selected text up" },
        ["L"] = { ">gv", desc = "Increase indent tab" },
      },
    },
  },
}
