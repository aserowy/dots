#!/usr/bin/env nu

let wm_hypr = 'Hyprland'
let wm_sway = 'sway'

let predefined = [
    [name wm command];
    [area $wm_hypr { || slurp }]
    [output $wm_hypr { || slurp -o }]
    [window $wm_hypr { || (get_hypr_window_areas) | slurp }]
    [area $wm_sway { || slurp }]
    [output $wm_sway { || slurp -o }]
    [window $wm_sway { || swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp }]
]

def main [action: string] {
    let current_wm = (get_current_wm)

    let command = ($predefined
        | where $it.name == $action and $it.wm == $current_wm
        | first
        | get command)

    let area = (do $command
        | str join ""
        | str trim)

    (grim -g $"\"($area)\"" -) | (swappy -f -)
}

def get_current_wm [] {
    $env.XDG_CURRENT_DESKTOP
}

def get_xdg_picture_dir [] {
    ($env.XDG_PICTURES_DIR | str replace '$HOME' $env.HOME)
}

def get_hypr_window_areas [] {
    let workspaces = (hyprctl monitors -j | jq -r 'map(.activeWorkspace.id)')
    let windows = (hyprctl clients -j | jq -r --argjson workspaces $workspaces 'map(select([.workspace.id] | inside($workspaces)))')

    ($windows | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
}
