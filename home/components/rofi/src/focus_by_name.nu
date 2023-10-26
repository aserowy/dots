#!/usr/bin/env nu

use workspace.nu *

def main [workspace_name: string = ''] {
    let wm = (get_current_wm)

    if $workspace_name == '' {
        (get_workspace_names_with_defaults | str join "\n")
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
