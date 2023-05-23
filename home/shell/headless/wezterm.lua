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

-- function(tab, tabs, panes, config, hover, max_width)
wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
    local title = tab.tab_title
    if not title or #title == 0 then
        title = tab.active_pane.title
    end

    local name = string.sub(title, 1, max_width)
    local padding = max_width - #name
    local pad_left = math.floor(padding / 2)
    local pad_right = math.ceil(padding / 2)

    return string.rep(" ", pad_left) .. name .. string.rep(" ", pad_right)
end)

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
    leader = { mods = "CTRL", key = "c" },
    keys = {
        { mods = "LEADER|CTRL", key = "c", action = wezterm.action.SendKey({ key = "c", mods = "CTRL" }) },
        { mods = "CTRL|SHIFT",  key = "p", action = wezterm.action.ActivateCommandPalette },
        { mods = "LEADER|CTRL", key = "f", action = "ShowLauncher" },
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
        {
            mods = "LEADER|CTRL",
            key = "r",
            action = wezterm.action.PromptInputLine({
                description = "Enter new name for tab",
                action = wezterm.action_callback(function(window, _, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end),
            }),
        },

        { mods = "CTRL|ALT",    key = "Enter", action = "ToggleFullScreen" },
        { mods = "CTRL|ALT",    key = "h",     action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
        { mods = "CTRL|ALT",    key = "l",     action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
        { mods = "CTRL|ALT",    key = "k",     action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
        { mods = "CTRL|ALT",    key = "j",     action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
        { mods = "CTRL|SHIFT",  key = "c",     action = wezterm.action({ CopyTo = "Clipboard" }) },
        { mods = "CTRL|SHIFT",  key = "v",     action = wezterm.action({ PasteFrom = "Clipboard" }) },
        { mods = "CTRL|SHIFT",  key = "u",     action = wezterm.action.CharSelect({ copy_on_select = false }) },
        { mods = "LEADER|CTRL", key = "n",     action = wezterm.action({ ActivateTabRelative = 1 }) },
        { mods = "LEADER|CTRL", key = "p",     action = wezterm.action({ ActivateTabRelative = -1 }) },
        { mods = "LEADER|CTRL", key = "h",     action = wezterm.action({ ActivatePaneDirection = "Left" }) },
        { mods = "LEADER|CTRL", key = "l",     action = wezterm.action({ ActivatePaneDirection = "Right" }) },
        { mods = "LEADER|CTRL", key = "k",     action = wezterm.action({ ActivatePaneDirection = "Up" }) },
        { mods = "LEADER|CTRL", key = "j",     action = wezterm.action({ ActivatePaneDirection = "Down" }) },
        { mods = "LEADER|CTRL", key = "z",     action = "TogglePaneZoomState" },
    },
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    M.default_prog = { "pwsh.exe" }
end

return M
