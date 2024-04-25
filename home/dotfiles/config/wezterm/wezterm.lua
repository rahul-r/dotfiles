local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Gruvbox Dark (Gogh)"

config.font = wezterm.font("DroidSansMono NFM")

config.hide_tab_bar_if_only_one_tab = false
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.window_close_confirmation = "NeverPrompt"

config.window_background_opacity = 0.9
config.text_background_opacity = 0.8
config.window_background_gradient = {
	colors = { "#000000", "#222222" },
	orientation = { Linear = { angle = -45.0 } },
}

config.keys = {
	{
		key = "F11",
		action = wezterm.action.ToggleFullScreen,
	},
}

return config
