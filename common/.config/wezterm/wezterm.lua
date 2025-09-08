local wezterm = require("wezterm")
local ui = require("ui")
local keybindings = require("keybindings")

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

ui.setup(config)
keybindings.setup(config)

return config
