local wezterm = require("wezterm")

local M = {}

-- Rosé Pine — same palette as darwin/.config/ghostty/themes/rosepine and
-- darwin/.config/rio/themes/rosepine.toml.
local scheme = {
	foreground = "#bdb9cf",
	background = "#191724",
	cursor_bg = "#c4a7e7",
	cursor_border = "#c4a7e7",
	cursor_fg = "#191724",
	selection_fg = "#e0def4",
	selection_bg = "#2a273f",
	ansi = { "#26233a", "#d97a96", "#469b9f", "#e6b482", "#9ccfd8", "#c4a7e7", "#dcb0ad", "#bdb9cf" },
	brights = { "#6e6a86", "#eb6f92", "#31748f", "#f6c177", "#9ccfd8", "#c4a7e7", "#ebbcba", "#d6d3e6" },
}

function M.setup(config)
	-- Font settings
	config.default_cursor_style = "SteadyBlock"
	config.font = wezterm.font("FiraCode Nerd Font Mono")
	config.font_size = 14.0
	config.line_height = 1.2

	-- Window settings
	config.window_decorations = "RESIZE"
	config.window_background_opacity = 0.80
	config.macos_window_background_blur = 24
	config.window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}

	-- macOS: option key sends Alt/Meta instead of composing accented characters
	config.send_composed_key_when_left_alt_is_pressed = false
	config.send_composed_key_when_right_alt_is_pressed = false

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
