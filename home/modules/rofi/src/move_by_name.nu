#!/usr/bin/env nu

use workspace.nu *

def main [workspace_name: string = ''] {
    let wm = (get_current_wm)

    if $workspace_name == '' {
        (get_workspace_names_with_defaults | str join "\n")
    } else {
        move_to_workspace $wm $workspace_name
    }
}

def move_to_workspace [wm: string, name: string] {
    match $wm {
        'Hyprland' => { run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch movetoworkspace $"name:($name)" | ignore },
        'sway' => { run-external --redirect-stdout --redirect-stderr 'swaymsg' move container to workspace $name | ignore }
    }
}
