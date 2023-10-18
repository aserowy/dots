#!/usr/bin/env nu

use list_workspaces_by_name.nu *

def main [workspace_name: string = ''] {
    let wm = (get_current_wm)
    let workspaces = (get_workspaces_by_name)

    if $workspace_name == '' {
        $workspaces
    } else {
        focus_workspace $wm $workspace_name
    }
}

def focus_workspace [wm: string, name: string] {
    match $wm {
        'Hyprland' => { run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch workspace $"name:($name)" | ignore },
        'sway' => { run-external --redirect-stdout --redirect-stderr 'swaymsg' workspace $name | ignore }
    }
}

def get_current_wm [] {
    $env.XDG_CURRENT_DESKTOP
}
