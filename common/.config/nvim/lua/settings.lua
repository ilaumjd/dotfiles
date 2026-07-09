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

-- Treesitter parsers (luarocks) ───────────────────────────────────────────────
-- Neovim loads parsers from `parser/{lang}.so` on the runtimepath but never
-- builds them. luarocks installs each parser (compiled .so + queries) into a
-- nested rock dir that isn't on the rtp by default. A parser .so is plain C (no
-- Lua linkage), so the rocks-<ver> tree is glob'd version-agnostically — install
-- with the plain luarocks VM, no --lua-version. Prereq: `brew install luarocks`.
local ts_site = vim.fn.stdpath("data") .. "/site"

-- Parsers to keep installed. Missing ones are fetched via luarocks in the
-- background on startup; the parser lights up on the next launch (the install
-- finishes after the rtp loop below has already run). Add a language here
-- instead of running luarocks by hand.
local ts_ensure = { "go", "ruby" }
if vim.fn.executable("luarocks") == 1 then
	for _, lang in ipairs(ts_ensure) do
		if vim.fn.glob(ts_site .. "/lib/luarocks/rocks-*/tree-sitter-" .. lang .. "/") == "" then
			vim.system(
				{ "luarocks", "--tree=" .. ts_site, "install", "tree-sitter-" .. lang },
				{},
				function(o)
					local msg = o.code == 0 and ("installed tree-sitter-" .. lang .. " — restart nvim")
						or ("tree-sitter-" .. lang .. " install failed:\n" .. (o.stderr or ""))
					vim.schedule(function()
						vim.notify(msg, o.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
					end)
				end
			)
		end
	end
end

-- Put every installed parser (+ its queries) on the runtimepath. The FileType
-- autocmd in autocmds.lua then starts highlighting for any language found here.
for _, dir in ipairs(vim.fn.glob(ts_site .. "/lib/luarocks/rocks-*/tree-sitter-*/*/", true, true)) do
	vim.opt.runtimepath:prepend(dir)
end

-- Misc ──────────────────────────────────────────────────────────────────────

vim.o.mouse = "a"
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- vim: ts=2 sts=2 sw=2 et
