#!/usr/bin/env nu

use list_workspaces_by_name.nu *

def main [workspace_name: string = ''] {
    let wm = (get_current_wm)
    let workspaces = (get_workspaces_by_name)

    if $workspace_name == '' {
        $workspaces
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

def get_current_wm [] {
    $env.XDG_CURRENT_DESKTOP
}
