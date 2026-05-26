-- [[ Settings ]]
-- Core Neovim options. Must load before plugins.

-- Global variables ──────────────────────────────────────────────────────────

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

-- Disable optional language providers (not needed — all plugins are Lua)
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Display & UI ──────────────────────────────────────────────────────────────

vim.o.number = true
vim.o.relativenumber = false
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.scrolloff = 10
vim.o.sidescrolloff = 8
vim.o.showmode = false
vim.o.wrap = false
vim.o.linebreak = true

-- Editing ───────────────────────────────────────────────────────────────────

vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.breakindent = true
vim.o.undofile = true
vim.o.confirm = true
vim.o.inccommand = "split"
vim.o.completeopt = "menu,menuone,noselect"

-- Search / Navigation ───────────────────────────────────────────────────────

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.o.updatetime = 250

-- Splits ────────────────────────────────────────────────────────────────────

vim.o.splitright = true
vim.o.splitbelow = true

-- Misc ──────────────────────────────────────────────────────────────────────

vim.o.mouse = "a"
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- vim: ts=2 sts=2 sw=2 et
