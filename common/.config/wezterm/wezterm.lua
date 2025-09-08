local wezterm = require("wezterm")

---@diagnostic disable: undefined-global
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.default_cursor_style = "BlinkingUnderline"
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 14.0
config.line_height = 1.2
config.window_background_opacity = 1.0

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

local scheme = wezterm.get_builtin_color_schemes()["Astrodark (Gogh)"]
config.color_schemes = {
	["scheme"] = scheme,
}
config.color_scheme = "scheme"

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
local inactive = {
	bg_color = scheme.background,
	fg_color = scheme.foreground,
}
config.colors = {
	tab_bar = {
		background = scheme.background,
		active_tab = {
			bg_color = scheme.foreground,
			fg_color = scheme.background,
		},
		inactive_tab = inactive,
		new_tab = inactive,
	},
}

config.enable_wayland = true

-- Keybindings to mimic tmux
config.keys = {
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "w",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "\\",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
}

config.leader = { key = "s", mods = "CMD", timeout_milliseconds = 1000 }

return config
