local wezterm = require("wezterm")

local colors = {
	background = "#212121",
	foreground = "#545454",
	button = {
		active = {
			bg = "#82aaff",
			text = "#ffffff",
		},
		inactive = {
			bg = "#89ddff",
			text = "#545454",
			hover = "#c9c9c9",
		},
	},
}

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
		{ Foreground = { Color = colors.button.active.text } },
		{ Text = cwd },
		{ Background = { Color = colors.foreground } },
		{ Text = battery },
		{ Foreground = { Color = colors.button.inactive.text } },
		{ Background = { Color = colors.button.inactive.bg } },
		{ Text = "  " .. date .. " " },
		{ Foreground = { Color = colors.button.active.text } },
		{ Background = { Color = colors.button.active.bg } },
		{ Text = hostname },
	}))
end)

return {
	-- domains
	default_prog = { "wsl.exe" },

	ssh_domains = {
		{
			name = "debian.wsl",
			remote_address = "localhost:2222",
			username = "serowy",
		},
	},

	-- theming
	color_scheme = "MaterialDarker",

	colors = {
		tab_bar = {
			background = colors.background,
			active_tab = {
				bg_color = colors.button.active.bg,
				fg_color = colors.button.active.text,
			},
			inactive_tab = {
				bg_color = colors.button.inactive.bg,
				fg_color = colors.button.inactive.text,
			},
			inactive_tab_hover = {
				bg_color = colors.button.inactive.bg,
				fg_color = colors.button.inactive.hover,
			},
			new_tab = {
				bg_color = colors.foreground,
				fg_color = colors.button.inactive.hover,
			},
			new_tab_hover = {
				bg_color = colors.foreground,
				fg_color = colors.button.inactive.hover,
			},
		},
	},

	window_background_opacity = 0.9,

	-- font
	font = wezterm.font("FiraCode NF", { weight = "Thin" }),
	line_height = 1.1,

	-- key mappings
	disable_default_key_bindings = true,

	leader = { mods = "CTRL|ALT", key = "t" },
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

		{ mods = "CTRL|SHIFT", key = "c", action = wezterm.action({ CopyTo = "Clipboard" }) },
		{ mods = "CTRL|SHIFT", key = "v", action = wezterm.action({ PasteFrom = "Clipboard" }) },
	},
}
