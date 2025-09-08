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
		leader_key("1", wezterm.action.ActivateTab(0)),
		leader_key("2", wezterm.action.ActivateTab(1)),
		leader_key("3", wezterm.action.ActivateTab(2)),
		leader_key("4", wezterm.action.ActivateTab(3)),
		leader_key("5", wezterm.action.ActivateTab(4)),
		leader_key("6", wezterm.action.ActivateTab(5)),
		leader_key("7", wezterm.action.ActivateTab(6)),
		leader_key("8", wezterm.action.ActivateTab(7)),
		leader_key("9", wezterm.action.ActivateTab(8)),
		leader_key("0", wezterm.action.ActivateTab(9)),
	}
	config.leader = { key = "s", mods = "CMD", timeout_milliseconds = 1000 }
end

return M
