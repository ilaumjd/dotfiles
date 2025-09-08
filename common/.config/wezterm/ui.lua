local wezterm = require("wezterm")

local M = {}

function M.setup(config)
	local scheme = wezterm.get_builtin_color_schemes()["Astrodark (Gogh)"]

	local inactive = {
		bg_color = scheme.background,
		fg_color = scheme.foreground,
	}

	config.default_cursor_style = "BlinkingUnderline"
	config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
	config.font_size = 14.0
	config.line_height = 1.2

	-- Window settings
	config.window_background_opacity = 1.0
	config.window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}

	-- Tab bar settings
	config.hide_tab_bar_if_only_one_tab = true
	config.tab_bar_at_bottom = false
	config.use_fancy_tab_bar = false

	-- Color scheme
	config.color_schemes = {
		["scheme"] = scheme,
	}
	config.color_scheme = "scheme"
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
end

return M
