local wezterm = require("wezterm")

local M = {}

local function leader_key(key, action)
	return {
		key = key,
		mods = "LEADER",
		action = action,
	}
end

function M.setup(config)
	config.keys = {
		leader_key("t", wezterm.action.SpawnTab("CurrentPaneDomain")),
		leader_key("x", wezterm.action.CloseCurrentTab({ confirm = true })),
		leader_key("w", wezterm.action.CloseCurrentPane({ confirm = true })),
		leader_key("\\", wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" })),
		leader_key("-", wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" })),
		leader_key("h", wezterm.action.ActivatePaneDirection("Left")),
		leader_key("j", wezterm.action.ActivatePaneDirection("Down")),
		leader_key("k", wezterm.action.ActivatePaneDirection("Up")),
		leader_key("l", wezterm.action.ActivatePaneDirection("Right")),
	}
	config.leader = { key = "s", mods = "CMD", timeout_milliseconds = 1000 }
end

return M
