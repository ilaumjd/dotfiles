-- [[ Editor Plugins ]]
-- Text objects, surround, substitution, breadcrumb, tmux navigation

-- Text objects (mini.ai)
require("mini.ai").setup({
	mappings = { around_next = "aa", inside_next = "ii" },
	n_lines = 500,
})

-- Surround (mini.surround)
require("mini.surround").setup()

-- Smart substitution operator
vim.pack.add({ _G.gh("gbprod/substitute.nvim") })
require("substitute").setup({})

-- Breadcrumb (winbar via dropbar.nvim)
vim.pack.add({ _G.gh("Bekaboo/dropbar.nvim") })
require("dropbar").setup({})

-- Seamless nvim/tmux pane navigation
vim.pack.add({ _G.gh("christoomey/vim-tmux-navigator") })

-- Send context from nvim to pi via unix socket
vim.pack.add({ _G.gh("carderne/pi-nvim") })
require("pi-nvim").setup({})

-- vim: ts=2 sts=2 sw=2 et
