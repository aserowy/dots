#!/usr/bin/env nu

use workspace.nu *

def main [workspace_name: string = ''] {
    if $workspace_name == '' {
        (get_workspace_names_with_defaults | str join "\n")
    } else {
        (focus_workspace $workspace_name)
    }
}

def focus_workspace [name: string] {
    let wm = (get_current_wm)

    match $wm {
        'Hyprland' => { (hyprctl dispatch workspace $'name:($name)' | ignore) },
        'sway' => { (swaymsg workspace $name | ignore) }
    }
}
