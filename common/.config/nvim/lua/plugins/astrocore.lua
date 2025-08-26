-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
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
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        clipboard = "unnamedplus", -- Sync with system clipboard
        completeopt = "menu,menuone,noselect",
        expandtab = true, -- Use spaces instead of tabs
        mouse = "a", -- Enable mouse mode
        shiftwidth = 2, -- Size of an indent
        ignorecase = true, -- Ignore case
        smartcase = true, -- Don't ignore case with capitals
        smartindent = true, -- Insert indents automatically
        splitbelow = true, -- Put new windows below current
        splitright = true, -- Put new windows right of current
        tabstop = 2, -- Number of spaces tabs count for
        termguicolors = true, -- True color support
        timeoutlen = 300, -- For which-key plugin
        undofile = true,
        cursorline = true,
        linebreak = true,
        scrolloff = 5,
        sidescrolloff = 8,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- disable
        ["<Leader>c"] = false,
        ["<Leader>C"] = false,
        ["[b"] = false,
        ["]b"] = false,

        -- overrides
        ["<Leader>fO"] = { function() require("snacks").picker.recent() end, desc = "Find old files" },
        ["<Leader>fo"] = {
          function() require("snacks").picker.recent { filter = { cwd = true } } end,
          desc = "Find old files (cwd)",
        },

        -- navigate buffer tabs
        ["J"] = { function() require("snacks").picker.buffers() end, desc = "Find buffers" },
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
