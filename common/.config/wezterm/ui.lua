local wezterm = require("wezterm")

local M = {}

function M.setup(config)
	local scheme = wezterm.get_builtin_color_schemes()["Astrodark (Gogh)"]

	-- Font settings
	config.default_cursor_style = "BlinkingUnderline"
	config.font = wezterm.font("FiraCode Nerd Font")
	config.font_size = 14.0
	config.line_height = 1.2

	-- Window settings
	config.window_decorations = "RESIZE"
	config.window_background_opacity = 1.0
	config.window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}

	-- Color scheme
	config.color_schemes = {
		["scheme"] = scheme,
	}
	config.color_scheme = "scheme"

	-- Tab colors
	local active = {
		bg_color = scheme.foreground,
		fg_color = scheme.background,
	}
	local inactive = {
		bg_color = scheme.background,
		fg_color = scheme.foreground,
	}
	config.colors = {
		tab_bar = {
			background = scheme.background,
			active_tab = active,
			inactive_tab = inactive,
			new_tab = inactive,
		},
	}

	-- Tab bar settings
	config.hide_tab_bar_if_only_one_tab = true
	config.tab_bar_at_bottom = false
	config.use_fancy_tab_bar = false

	config.window_content_alignment = {
		horizontal = "Center",
		vertical = "Center",
	}
end

return M
