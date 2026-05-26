# AGENTS.md - Neovim Configuration

## Overview

This is AstroNvim-based Neovim configuration using Lazy.nvim for plugin management.

## Directory Structure

```
nvim/
├── init.lua          # Bootstrap lazy.nvim and load configs
├── lua/
│   ├── lazy_setup.lua    # Plugin manager setup
│   ├── polish.lua       # Last-run configuration
│   ├── plugins/          # Plugin specs
│   │   ├── astrocore.lua    # Core mappings & options
│   │   ├── avante.lua       # AI code assistant
│   │   ├── buffer.lua       # Buffer management
│   │   ├── snacks.lua       # UI utilities
│   │   └── ...
│   └── community.lua    # Community plugins
├── .stylua.toml      # Lua formatting config
├── neovim.yml        # Selene (Lua linter) config
└── .luarc.json       # Lua LSP config
```

## Build/Lint/Format Commands

### Format Lua

```bash
stylua lua_file.lua
```

### Check Syntax

```bash
# Using Neovim's built-in
nvim --headless -c "lua vim.diagnostic.disable()" -c "quit" file.lua

# Or with selene
selene check .
```

## Code Style

### stylua.toml

```toml
column_width = 120
indent_width = 2
indent_type = "Spaces"
quote_style = "AutoPreferDouble"
call_parentheses = "None"
collapse_simple_statement = "Always"
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Functions | snake_case | `my_function()` |
| Modules | snake_case | `require("my_module")` |
| Plugin specs | snake_case | `plugins/buffer.lua` |
| Mappings | camelCase | `["<Leader>key"]` |
| Variables | snake_case | `local my_var = 1` |

### Imports

```lua
local M = require("my_module")
local utils = require("utils")
```

### Plugin Specs

```lua
---@type LazySpec
return {
  "author/plugin",
  opts = {},
  config = function()
    -- setup code
  end,
}
```

### Mappings

```lua
-- Use desc for documentation
["<Leader>key"] = { "<cmd>Command<CR>", desc = "Description" }

-- Function mappings
["<Leader>fn"] = { function() do_something() end, desc = "Do something" }
```

### Options

```lua
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.mouse = "a"
```

### Autocommands

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "vim" },
  callback = function()
    -- do something
  end,
})
```

## Error Handling

```lua
-- Safe module loading
if pcall(require, "module") then
  -- module loaded
end

-- User-facing errors
vim.notify("Error message", vim.log.levels.ERROR)
```

## Type Annotations

```lua
---@type LazySpec
---@type AstroCoreOpts
---@type LazyConfig
```

## Testing

Run plugin tests if available:
```bash
nvim --headless -c "PlenaryBustedFile test_file.lua" -c "quit"
```
