#!/usr/bin/env nu

export def get_default_workspace_names [] {
    [dots gaming notes social work]
}

export def get_workspace_names_with_defaults [] {
    let predefined = (get_default_workspace_names)

    let wm = (get_current_wm)
    let workspaces = (get_workspaces $wm
        | get name
        | append $predefined
        | uniq
        | sort --ignore-case --natural)

    $workspaces
}

export def get_current_wm [] {
    $env.XDG_CURRENT_DESKTOP
}

export def get_current_workspace_id [wm: string] {
    match $wm {
        'Hyprland' => { (hyprctl activeworkspace -j | from json).id },
        'sway' => { 0 }
    }
}

export def get_workspaces [wm: string] {
    match $wm {
        'Hyprland' => (hyprctl workspaces -j | from json),
        'sway' => (swaymsg -t get_workspaces -r | from json)
    }
}
