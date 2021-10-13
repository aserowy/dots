local wezterm = require("wezterm")

local onedark = {
	foreground = "#ABB2BF",
	background = "#282c34",
	cursor_bg = "#828997",
	cursor_border = "#828997",
	cursor_fg = "#ABB2BF",
	selection_bg = "#3E4451",
	selection_fg = "#ABB2BF",
	ansi = { "#3E4451", "#BE5046", "#98c379", "#D19A66", "#528BFF", "#c678dd", "#56b6c2", "#ABB2BF" },
	brights = { "#5C6370", "#e06c75", "#98c379", "#e5c07b", "#61afef", "#c678dd", "#56b6c2", "#ABB2BF" },
}

local theme = onedark

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
		{ Foreground = { Color = theme.foreground } },
		{ Text = cwd },
		{ Background = { Color = theme.brights[1] } },
		{ Text = battery },
		{ Foreground = { Color = theme.background } },
		{ Background = { Color = theme.brights[6] } },
		{ Text = "  " .. date .. " " },
		{ Foreground = { Color = theme.background } },
		{ Background = { Color = theme.brights[5] } },
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
	color_scheme = "OneDark",

	color_schemes = {
		["OneDark"] = onedark,
	},

	colors = {
		tab_bar = {
			background = "#212836",
			active_tab = {
				bg_color = theme.background,
				fg_color = theme.foreground,
			},
			inactive_tab = {
				bg_color = "#212836",
				fg_color = theme.brights[1],
			},
			inactive_tab_hover = {
				bg_color = theme.brights[1],
				fg_color = theme.foreground,
			},
			new_tab = {
				bg_color = "#212836",
				fg_color = theme.brights[1],
			},
			new_tab_hover = {
				bg_color = theme.brights[1],
				fg_color = theme.foreground,
			},
		},
	},

	inactive_pane_hsb = {
		saturation = 0.7,
		brightness = 0.6,
	},

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

	-- overwrites background color for onedark transpancy
	M.window_background_gradient = {
		colors = {
			theme.background,
			theme.background,
		},
	}

	M.window_background_opacity = 0.9
else
	M.leader = { mods = "CTRL", key = "t" }

	M.font = wezterm.font_with_fallback({
		{ family = "FiraCode Nerd Font Mono", weight = "Light", stretch = "Normal", italic = false },
	})

	M.hide_tab_bar_if_only_one_tab = true
end

return M
