# AGENTS.md

## Neovim config

- **Entry order**: `init.lua` → settings → plugins → keymaps → autocmds
- **Plugin manager**: native `vim.pack.add()` (Neovim 0.11+), NOT lazy/packer
- **Plugin files**: `lua/plugins/{ui,editor,lsp,format,lint,completion,git,files}.lua`
- **Picker**: snacks.nvim, not telescope
- **LSP API**: `vim.lsp.config()` + `vim.lsp.enable()` (0.11 native)

## Commands

```bash
stylua lua/   # Format Lua
selene lua/   # Lint Lua (config: selene.toml + vim.toml)
```

## Conventions

- `snake_case` for functions/vars, `camelCase` for mapping keys
- Use `desc` in keymaps for which-key docs
- Macro recording disabled by default (`map q <Nop>`), toggle `<leader>uq`
- `_G.gh("user/repo")` expands to `"https://github.com/user/repo"`

## Quirks

- Build hook: LuaSnip runs `make install_jsregexp` on install/update
- Don't modify git submodule content under `common/.config/zsh/`
