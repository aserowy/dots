local wezterm = require("wezterm")

wezterm.on("update-right-status", function(window, pane)
	local date = wezterm.strftime("%Y-%m-%d %H:%M")
	local hostname = " " .. wezterm.hostname() .. " "

	local cwd = ""
	if pane:get_current_working_dir() ~= nil then
		cwd = " " .. pane:get_current_working_dir():sub(8) .. " "
	end

	local battery = ""
	for _, b in ipairs(wezterm.battery_info()) do
		battery = "  " .. string.format("%.0f%%", b.state_of_charge * 100) .. " "
	end

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#c9c9c9" } },
		{ Text = cwd },
		{ Background = { Color = "#302b2a" } },
		{ Text = battery },
		{ Background = { Color = "#9d602a" } },
		{ Text = "  " .. date .. " " },
		{ Background = { Color = "#a7463d" } },
		{ Text = hostname },
	}))
end)

return {
	-- domains
	ssh_domains = {
		{
			name = "debian.wsl",
			remote_address = "localhost:2222",
			username = "serowy",
		},
	},

	-- theming
	color_scheme = "Sundried",

	colors = {
		tab_bar = {
			background = "#1a1818",
			active_tab = {
				bg_color = "#a7463d",
				fg_color = "#c9c9c9",
			},
			inactive_tab = {
				bg_color = "#4d4e48",
				fg_color = "#c9c9c9",
			},
			inactive_tab_hover = {
				bg_color = "#4d4e48",
				fg_color = "#c9c9c9",
			},
			new_tab = {
				bg_color = "#302b2a",
				fg_color = "#808080",
			},
			new_tab_hover = {
				bg_color = "#302b2a",
				fg_color = "#c9c9c9",
			},
		},
	},

	window_background_opacity = 0.9,

	-- font
	font = wezterm.font("FiraCode NF", { weight = "Thin" }),
	line_height = 1.1,

	-- key mappings
	disable_default_key_bindings = true,

	leader = { mods = "CTRL", key = "t" },
	keys = {
		{ mods = "LEADER", key = "a", action = "ShowLauncher" },

		{ mods = "LEADER", key = "w", action = "QuickSelect" },
		{ mods = "LEADER", key = "/", action = wezterm.action({ Search = { CaseSensitiveString = "" } }) },
		{ mods = "LEADER", key = "y", action = "ActivateCopyMode" },

		{ mods = "LEADER", key = "v", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
		{ mods = "LEADER", key = "x", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },

		{ mods = "LEADER", key = "n", action = wezterm.action({ ActivateTabRelative = 1 }) },
		{ mods = "LEADER", key = "p", action = wezterm.action({ ActivateTabRelative = -1 }) },

		{ mods = "LEADER", key = "h", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ mods = "LEADER", key = "l", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
		{ mods = "LEADER", key = "k", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ mods = "LEADER", key = "j", action = wezterm.action({ ActivatePaneDirection = "Down" }) },

		{ mods = "CTRL|ALT", key = "h", action = wezterm.action({ AdjustPaneSize = { "Left", 1 } }) },
		{ mods = "CTRL|ALT", key = "l", action = wezterm.action({ AdjustPaneSize = { "Right", 1 } }) },
		{ mods = "CTRL|ALT", key = "k", action = wezterm.action({ AdjustPaneSize = { "Up", 1 } }) },
		{ mods = "CTRL|ALT", key = "j", action = wezterm.action({ AdjustPaneSize = { "Down", 1 } }) },

		{ mods = "LEADER", key = "z", action = "TogglePaneZoomState" },

		{ mods = "ALT", key = "Enter", action = "ToggleFullScreen" },

		{ mods = "CTRL", key = "d", action = wezterm.action({ CloseCurrentPane = { confirm = false } }) },

		{ mods = "CTRL|SHIFT", key = "c", action = wezterm.action({ CopyTo = "Clipboard" }) },
		{ mods = "CTRL|SHIFT", key = "v", action = wezterm.action({ PasteFrom = "Clipboard" }) },
	},
}
