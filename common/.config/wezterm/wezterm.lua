local wezterm = require("wezterm")

---@diagnostic disable: undefined-global
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.default_cursor_style = "BlinkingUnderline"
config.font = wezterm.font("IntoneMono Nerd Font")
config.font_size = 15.0
config.hide_tab_bar_if_only_one_tab = true
config.line_height = 1.2
config.window_background_opacity = 1.0

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

local scheme = wezterm.get_builtin_color_schemes()["Astrodark (Gogh)"]
-- scheme.cursor_fg = "#373837"
-- scheme.cursor_bg = "#ededed"
config.color_schemes = {
	["scheme"] = scheme,
}
config.color_scheme = "scheme"

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

-- config.front_end = "WebGpu"

config.enable_wayland = true

return config
