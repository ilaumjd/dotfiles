-- [[ Buffer Manager ]]
-- Opens a floating window with listed buffers.
--   <Enter> / click → jump to buffer
--   q / <Esc>      → close
--   Pressing J again focuses the existing window

---@class BufManagerEntry
---@field buf integer
---@field path string

local M = {}
local manager_win = nil ---@type integer?

function M.open()
	-- If already open, just focus it
	if manager_win and vim.api.nvim_win_is_valid(manager_win) then
		vim.api.nvim_set_current_win(manager_win)
		return
	end
	-- Collect listed buffers, sorted by number
	local bufs = {}
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(b)
		if vim.bo[b].buflisted
			and vim.bo[b].buftype == ""
			and name ~= ""
		then
			table.insert(bufs, b)
		end
	end
	table.sort(bufs)

	if #bufs == 0 then
		vim.notify("No buffers", vim.log.levels.WARN)
		return
	end

	-- Build display lines
	local lines = {}
	---@type BufManagerEntry[]
	local entries = {}
	for i, b in ipairs(bufs) do
		local name = vim.api.nvim_buf_get_name(b)
		local fname = vim.fn.fnamemodify(name, ":.")
		table.insert(lines, fname)
		entries[i] = { buf = b, path = name }
	end

	-- Floating window
	local w = math.min(60, vim.o.columns - 4)
	local h = math.min(#lines + 2, vim.o.lines - 6)
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = w,
		height = h,
		row = math.max(0, math.floor((vim.o.lines - h) / 2) - 2),
		col = math.max(0, math.floor((vim.o.columns - w) / 2)),
		style = "minimal",
		border = "rounded",
		title = " Buffers ",
		title_pos = "center",
	})

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	manager_win = win

	-- Reset tracker when the window closes
	vim.api.nvim_create_autocmd("WinClosed", {
		buffer = buf,
		once = true,
		callback = function()
			manager_win = nil
		end,
	})

	-- Buffer-local keymaps
	local bmap = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = buf, nowait = true, desc = desc })
	end

	---@return BufManagerEntry?
	local function entry_at_cursor()
		local line = vim.fn.line(".")
		return entries[line]
	end

	-- Block global custom mappings that shouldn't fire inside the popup
	local block_keys = { "H", "L", "J", "-", "x" }
	for _, k in ipairs(block_keys) do
		bmap(k, "<Nop>", "Blocked in popup")
	end

	bmap("q", "<cmd>close<CR>", "Close")
	bmap("<Esc>", "<cmd>close<CR>", "Close")

	bmap("<CR>", function()
		local entry = entry_at_cursor()
		if entry then
			vim.api.nvim_win_close(win, true)
			vim.api.nvim_set_current_buf(entry.buf)
		end
	end, "Open buffer")

	bmap("<LeftRelease>", function()
		local entry = entry_at_cursor()
		if entry then
			vim.api.nvim_win_close(win, true)
			vim.api.nvim_set_current_buf(entry.buf)
		end
	end, "Open buffer (click)")

	-- Start cursor on the first entry
	pcall(vim.api.nvim_win_set_cursor, win, { 1, 0 })
end

return M

-- vim: ts=2 sts=2 sw=2 et
