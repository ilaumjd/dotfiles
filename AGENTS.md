# AGENTS.md - Development Guidelines for Dotfiles

## Overview

This is a dotfiles repository containing shell scripts and Lua configurations for managing system configurations across macOS (darwin) and Linux (void) systems.

## Repository Structure

```
dotfiles/
├── apply.sh          # Main stow script for linking configs
├── common/           # Shared configs (zsh, nvim, tmux, wezterm)
│   └── .config/
│       ├── nvim/    # Neovim Lua configuration (see nvim/AGENTS.md)
│       ├── zsh/     # Zsh plugins and configs
│       └── tmux/   # Tmux config
├── darwin/           # macOS-specific configs (yabai, sketchybar, skhd)
├── void/             # Linux/Void-specific configs (hyprland, waybar, etc.)
└── scripts/          # Utility scripts
```

## Build/Lint/Test Commands

### Shell Scripts (bash/zsh)

**Manual Linting:**
```bash
# Lint shell scripts with shellcheck
shellcheck script.sh

# Format shell scripts with shfmt
shfmt -bn -ci -i 2 -ln bash script.sh

# Check zsh syntax
zsh -n script.zsh
```

**In CI workflow** (see `.github/workflows/linting.yml`):
- `shellcheck` - Shell script linting
- `shfmt -bn -ci -i 2 -ln bash -s -sr` - Shell script formatting
- `zsh -n` - Zsh syntax checking
- `mdformat --check --wrap 120` - Markdown formatting

### Neovim Lua

See [common/.config/nvim/AGENTS.md](common/.config/nvim/AGENTS.md) for Neovim-specific guidelines.

## Code Style Guidelines

### Shell Scripts

**Shebang:**
```bash
#!/bin/bash       # For bash scripts
#!/bin/sh         # For POSIX scripts (sketchybar uses this)
#!/usr/bin/env bash  # When portable
```

**Indentation:**
- 2 spaces (see `.editorconfig` for tmux-session-wizard)
- Tab for general configs (from editorconfig)

**Variables:**
```bash
# Good
local_var="value"
export GLOBAL_VAR="value"
CONSTANT_VAR=123

# Lowercase for locals, uppercase for exported/constants
```

**Conditionals:**
```bash
# Use [[ ]] for bash/zsh
if [[ "$var" == "value" ]]; then
  do_something
fi

# For string comparisons, quote variables
if [[ "${var//:/}" == *"${other//-/}"* ]]; then
  continue
fi
```

**Functions:**
```bash
# Use local for function variables
my_function() {
  local input="$1"
  local result=""

  # function body
  return result
}
```

**Error Handling:**
```bash
# Option flags at top
set -euo pipefail

# For specific operations that may fail
command || true  # Continue on failure
command || exit 1  # Exit on failure
```

**ShellCheck Directives:**
```bash
# shellcheck disable=SC2034  # For unused variables
# shellcheck disable=SC2086  # For word splitting (sometimes needed)
```

### Configuration Files

**YAML:**
```yaml
---
base: lua51
indent_style: space
indent_size: 2
```

**General:**
- Use `lf` line endings (Unix)
- Trim trailing whitespace
- Insert final newline
- 120 character line wrap for markdown

## Error Handling Conventions

- `set -euo pipefail` for scripts that should fail fast
- Check exit codes: `if ! command; then ...`
- Use `|| true` sparingly for optional operations
- Log errors to stderr: `echo "Error" >&2`

## Naming Conventions

### Shell Variables
- Local variables: `snake_case`
- Environment/exports: `UPPER_SNAKE_CASE`
- Constants: `UPPER_SNAKE_CASE`

### Files
- Shell scripts: `*.sh`
- Lua modules: `*.lua`
- YAML configs: `*.yml`

## Special Considerations

1. **Cross-Platform**: Scripts may run on macOS or Linux - check `$OSTYPE`
2. **Submodules**: Some configs are git submodules - don't modify upstream
3. **Stow**: Main `apply.sh` uses GNU stow to symlink configs to `$HOME`
4. **Shell Portability**: Prefer POSIX sh for maximum compatibility
