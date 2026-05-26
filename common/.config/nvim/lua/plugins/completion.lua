-- [[ Completion ]]
-- blink.cmp + LuaSnip snippets

vim.pack.add({
	{ src = _G.gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
	{ src = _G.gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") },
})

require("luasnip").setup({})

require("blink.cmp").setup({
	keymap = {
		preset = "default",
		["<C-j>"] = { "select_next", "fallback_to_mappings" },
		["<C-k>"] = { "select_prev", "fallback_to_mappings" },
		["<C-h>"] = { "show_signature", "hide_signature", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = {
		documentation = { auto_show = false, auto_show_delay_ms = 500 },
	},
	sources = { default = { "lsp", "path", "snippets" } },
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "prefer_rust" },
	signature = { enabled = true },
})

-- vim: ts=2 sts=2 sw=2 et
