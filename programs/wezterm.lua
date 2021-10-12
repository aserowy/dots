local wezterm = require("wezterm")

local colors = {
	background = "#282c34",
	foreground = "#c678dd",
	button = {
		active = {
			bg = "#61afef",
			text = "#dcdfe4",
		},
		inactive = {
			bg = "#474e5d",
			text = "#dcdfe4",
			hover = "#dcdfe4",
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
		{ Background = { Color = colors.button.inactive.bg } },
		{ Text = battery },
		{ Foreground = { Color = colors.button.inactive.text } },
		{ Background = { Color = colors.foreground } },
		{ Text = "  " .. date .. " " },
		{ Foreground = { Color = colors.button.active.text } },
		{ Background = { Color = colors.button.active.bg } },
		{ Text = hostname },
	}))
end)

local M = {
	-- domains
	ssh_domains = {
		{
			name = "debian.wsl",
			remote_address = "localhost:2222",
			username = "serowy",
		},
		{
			name = "desktop-nixos",
			remote_address = "192.168.178.53:2022",
			username = "serowy",
		},
	},

	-- theming
	color_scheme = "OneHalfDark",

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
				bg_color = colors.button.inactive.bg,
				fg_color = colors.button.inactive.hover,
			},
			new_tab_hover = {
				bg_color = colors.background,
				fg_color = colors.button.inactive.hover,
			},
		},
	},

	inactive_pane_hsb = {
		saturation = 0.7,
		brightness = 0.6,
	},

	-- overwrites background color for onedark transpancy
	window_background_gradient = {
		colors = {
			"#0A0B0D",
			"#0A0B0D",
		},
	},

	window_background_opacity = 0.9,

	-- font
	line_height = 1.1,

	-- key mappings
	disable_default_key_bindings = true,

	keys = {
		{ mods = "LEADER|CTRL", key = "a", action = "ShowLauncher" },

		{ mods = "LEADER|CTRL", key = "w", action = "QuickSelect" },
		{ mods = "LEADER|CTRL", key = "/", action = wezterm.action({ Search = { CaseSensitiveString = "" } }) },
		{ mods = "LEADER|CTRL", key = "y", action = "ActivateCopyMode" },

		{
			mods = "LEADER|CTRL",
			key = "v",
			action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
		},
		{
			mods = "LEADER|CTRL",
			key = "x",
			action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
		},

		{ mods = "LEADER|CTRL", key = "n", action = wezterm.action({ ActivateTabRelative = 1 }) },
		{ mods = "LEADER|CTRL", key = "p", action = wezterm.action({ ActivateTabRelative = -1 }) },

		{ mods = "LEADER|CTRL", key = "h", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ mods = "LEADER|CTRL", key = "l", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
		{ mods = "LEADER|CTRL", key = "k", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ mods = "LEADER|CTRL", key = "j", action = wezterm.action({ ActivatePaneDirection = "Down" }) },

		{ mods = "CTRL|ALT", key = "h", action = wezterm.action({ AdjustPaneSize = { "Left", 1 } }) },
		{ mods = "CTRL|ALT", key = "l", action = wezterm.action({ AdjustPaneSize = { "Right", 1 } }) },
		{ mods = "CTRL|ALT", key = "k", action = wezterm.action({ AdjustPaneSize = { "Up", 1 } }) },
		{ mods = "CTRL|ALT", key = "j", action = wezterm.action({ AdjustPaneSize = { "Down", 1 } }) },

		{ mods = "LEADER|CTRL", key = "z", action = "TogglePaneZoomState" },

		{ mods = "ALT", key = "Enter", action = "ToggleFullScreen" },

		{ mods = "CTRL|SHIFT", key = "c", action = wezterm.action({ CopyTo = "Clipboard" }) },
		{ mods = "CTRL|SHIFT", key = "v", action = wezterm.action({ PasteFrom = "Clipboard" }) },
	},
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	M.default_prog = { "wsl.exe" }

	M.font = wezterm.font_with_fallback({
		{ family = "FiraCode NF", weight = "Thin" },
	})

	M.leader = { mods = "CTRL|ALT", key = "t" }
else
	M.leader = { mods = "CTRL", key = "t" }

	M.font = wezterm.font_with_fallback({
		{ family = "FiraCode Nerd Font", weight = "Light", stretch = "Normal", italic = false },
	})

	M.hide_tab_bar_if_only_one_tab = true
end

return M
