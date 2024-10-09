local wezterm = require("wezterm")

local onedark = {
    foreground = "#ABB2BF",
    background = "#282c34",
    cursor_bg = "#828997",
    cursor_border = "#828997",
    cursor_fg = "#ABB2BF",
    selection_bg = "#3E4451",
    selection_fg = "#ABB2BF",
    ansi = { "#3E4451", "#e06c75", "#98c379", "#e5c07b", "#61afef", "#c678dd", "#56b6c2", "#ABB2BF" },
    brights = { "#5C6370", "#e06c75", "#98c379", "#e5c07b", "#61afef", "#c678dd", "#56b6c2", "#ABB2BF" },
}

local bluloco = {
    foreground = "#b9c0cb",
    background = "#282c34",
    cursor_bg = "#ffcc00",
    cursor_border = "#ffcc00",
    cursor_fg = "#282c34",
    selection_bg = "#b9c0ca",
    selection_fg = "#272b33",
    ansi = { "#41444d", "#fc2f52", "#25a45c", "#ff936a", "#3476ff", "#7a82da", "#4483aa", "#cdd4e0" },
    brights = { "#8f9aae", "#ff6480", "#3fc56b", "#f9c859", "#10b1fe", "#ff78f8", "#5fb9bc", "#ffffff" },
}

local theme = bluloco

local M = {
    -- domains
    ssh_domains = {
        {
            name = "homeassistant",
            remote_address = "homeassistant:2022",
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
            background = "#21252b",
            active_tab = {
                bg_color = theme.background,
                fg_color = theme.foreground,
            },
            inactive_tab = {
                bg_color = "#21252b",
                fg_color = theme.brights[1],
            },
            inactive_tab_hover = {
                bg_color = theme.brights[1],
                fg_color = theme.foreground,
            },
            new_tab = {
                bg_color = "#21252b",
                fg_color = theme.brights[1],
            },
            new_tab_hover = {
                bg_color = theme.brights[1],
                fg_color = theme.foreground,
            },
        },
    },
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    inactive_pane_hsb = {
        saturation = 0.7,
        brightness = 0.6,
    },
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    -- font
    font = wezterm.font_with_fallback({
        { family = "FiraCode Nerd Font", weight = "Regular", stretch = "Normal", italic = false },
    }),
    font_size = 10.0,
    line_height = 1.1,
    -- key mappings
    disable_default_key_bindings = true,
    keys = {
        { mods = "CTRL|SHIFT", key = "c", action = wezterm.action({ CopyTo = "Clipboard" }) },
        { mods = "CTRL|SHIFT", key = "v", action = wezterm.action({ PasteFrom = "Clipboard" }) },
    },
    mouse_bindings = {
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "CTRL",
            action = wezterm.action.OpenLinkAtMouseCursor,
        },
        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = "CTRL",
            action = wezterm.action.IncreaseFontSize,
        },
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = "CTRL",
            action = wezterm.action.DecreaseFontSize,
        },
    },
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    M.default_prog = { "nu.exe" }
end

return M
