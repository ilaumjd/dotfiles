-- [[ UI Plugins ]]
-- Colorscheme, picker, dashboard, hints, statusline

-- Colorscheme
vim.pack.add({ _G.gh("AstroNvim/astrotheme") })
---@diagnostic disable-next-line: missing-fields
require("astrotheme").setup({
	style = {
		italic_comments = false,
	},
})
vim.cmd.colorscheme("astrodark")

-- snacks.nvim — picker, dashboard, indent (replaces mini.pick, mini.starter, mini.indentscope)
vim.pack.add({ _G.gh("folke/snacks.nvim") })

-- mini.nvim — statusline, clue, pairs (keep for modules snacks doesn't cover)
vim.pack.add({ _G.gh("echasnovski/mini.nvim") })

-- Statusline
local statusline = require("mini.statusline")
statusline.setup({ use_icons = vim.g.have_nerd_font })
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
	return "%2l:%-2v"
end

-- Glassy editor: strip the background off ONLY the main buffer so Ghostty's
-- opacity + blur show through on the code area. Panels (statusline, floats,
-- picker, dashboard) deliberately KEEP astrodark's solid backgrounds — their
-- dense text needs the contrast and turns unreadable over the blurred desktop.
-- Re-applied on every colorscheme load.
local function clear_bg(group)
	local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
	hl.bg = nil
	hl.ctermbg = nil
	vim.api.nvim_set_hl(0, group, hl)
end
local buffer_groups = {
	"Normal",
	"NormalNC",
	"SignColumn",
	"EndOfBuffer",
	"LineNr",
	"LineNrAbove",
	"LineNrBelow",
	"FoldColumn",
	"MsgArea",
	"NonText",
}
local function glassify_editor()
	for _, g in ipairs(buffer_groups) do
		clear_bg(g)
	end
	-- Line numbers use astrodark's darkest gray (#3A3E47), tuned for a solid dark
	-- background — it vanishes over the glassy backdrop. Brighten to a muted grey
	-- that stays readable but secondary.
	for _, g in ipairs({ "LineNr", "LineNrAbove", "LineNrBelow" }) do
		vim.api.nvim_set_hl(0, g, { fg = "#797D87" })
	end

	-- astrodark leaves StatusLineNC (and the filename section that links to it)
	-- with no background — a transparent gap in the middle of the bar. Fill it
	-- with StatusLine's color so the whole statusline is one solid, readable bar.
	local sl_bg = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false }).bg
	if sl_bg then
		local hl = vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false })
		hl.bg = sl_bg
		hl.ctermbg = nil
		vim.api.nvim_set_hl(0, "StatusLineNC", hl)
	end
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = glassify_editor })
glassify_editor()

-- Key hints (mini — snacks has no which-key equivalent)
require("mini.clue").setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
	},
	clues = {
		require("mini.clue").gen_clues.builtin_completion(),
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.marks(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.windows(),
	},
})

-- Autopairs (mini — snacks has no autopairs)
require("mini.pairs").setup()

-- Notifications (mini — replaces vim.notify)
require("mini.notify").setup()
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = require("mini.notify").make_notify()

-- ═══════════════════════════════════════════════════════════════
-- snacks.nvim
-- ═══════════════════════════════════════════════════════════════

---@diagnostic disable-next-line: missing-fields
require("snacks").setup({
	-- Picker: replace mini.pick
	picker = {
		sources = {
			files = { hidden = true, ignored = false },
			grep = { hidden = true, ignored = false },
			explorer = { hidden = true, ignored = false },
		},
		win = {
			input = {
				keys = {
					["<C-j>"] = { "list_down", mode = { "i", "n" } },
					["<C-k>"] = { "list_up", mode = { "i", "n" } },
				},
			},
		},
	},
	-- Dashboard (clean, minimal, centered)
	dashboard = {
		sections = {
			{
				text = [[
`7MN.   `7MF'`7MM"""YMM    .g8""8q.`7MMF'   `7MF'`7MMF'`7MMM.     ,MMF'
  MMN.    M    MM    `7  .dP'    `YM.`MA     ,V    MM    MMMb    dPMM  
  M YMb   M    MM   d    dM'      `MM VM:   ,V     MM    M YM   ,M MM  
  M  `MN. M    MMmmMM    MM        MM  MM.  M'     MM    M  Mb  M' MM  
  M   `MM.M    MM   Y  , MM.      ,MP  `MM A'      MM    M  YM.P'  MM  
  M     YMM    MM     ,M `Mb.    ,dP'   :MM;       MM    M  `YM'   MM  
.JML.    YM  .JMMmmmmMMM   `"bmmd"'      VF      .JMML..JML. `'  .JMML.


]],
				align = "center",
				padding = { 2, 4 },
			},
			-- Quick actions
			{ section = "keys", gap = 1, padding = 1 },
		},
		preset = {
			keys = {
				{ icon = " ", key = "n", desc = "New File  ", action = ":ene | startinsert" },
				{ icon = " ", key = "f", desc = "Find File  ", action = ':lua Snacks.dashboard.pick("files")' },
				{
					icon = " ",
					key = "o",
					desc = "Recent (cwd)  ",
					action = ':lua Snacks.dashboard.pick("oldfiles", { filter = { cwd = true } })',
				},
				{ icon = " ", key = "O", desc = "Recents  ", action = ':lua Snacks.dashboard.pick("oldfiles")' },
				{ icon = " ", key = "w", desc = "Find Word  ", action = ':lua Snacks.dashboard.pick("live_grep")' },
				{
					icon = " ",
					key = "'",
					desc = "Bookmarks  ",
					action = ':lua Snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") })',
				},
				{ icon = " ", key = "s", desc = "Last Session  ", action = ':lua Snacks.dashboard.pick("files")' },
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
		},
	},
	-- Indent guides: replace mini.indentscope
	indent = { enabled = true },
	-- Disable modules we don't need
	bigfile = { enabled = false },
	notifier = { enabled = false },
	scroll = { enabled = false },
	words = { enabled = false },
	zen = { enabled = false },
})

-- vim: ts=2 sts=2 sw=2 et
