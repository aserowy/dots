#!/usr/bin/env nu

use workspace.nu *

def main [workspace_name: string = ''] {
    if $workspace_name == '' {
        (get_workspace_names_with_defaults | str join "\n")
    } else {
        (move_to_workspace $workspace_name)
    }
}

def move_to_workspace [name: string] {
    let wm = (get_current_wm)

    match $wm {
        'Hyprland' => { (hyprctl dispatch movetoworkspace $name | ignore) },
        'sway' => { (swaymsg move container to workspace $name | ignore) }
    }
}
