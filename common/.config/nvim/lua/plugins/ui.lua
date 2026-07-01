-- [[ UI Plugins ]]
-- Colorscheme, picker, dashboard, hints, statusline

-- Colorscheme
-- rose-pine matches Ghostty's `theme = rosepine`, so the blurred backdrop that
-- bleeds through the glassy editor shares nvim's palette. Its built-in
-- `styles.transparent` handles Normal/floats/statusline/line-numbers for us —
-- no manual background stripping needed.
vim.pack.add({ _G.gh("rose-pine/neovim") })
require("rose-pine").setup({
	variant = "main",
	styles = {
		transparency = true,
		italic = false,
	},
	highlight_groups = {
		-- A bg color renders opaque in the terminal (it can't blur), so
		-- CursorLine/CursorColumn show up as a jarring solid bar across the
		-- glassy buffer. Drop them — the bright CursorLineNr still marks the row.
		CursorLine = { bg = "none" },
		CursorColumn = { bg = "none" },
		-- Selection was too dark to read over the blurred backdrop.
		Visual = { bg = "highlight_high", inherit = false },
	},
})
vim.cmd.colorscheme("rose-pine")

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
