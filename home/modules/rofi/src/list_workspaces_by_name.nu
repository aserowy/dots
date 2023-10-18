#!/usr/bin/env nu

export def get_workspaces_by_name [] {
    let predefined = [dots gaming notes social work]

    let wm = (get_current_wm)
    let workspaces = (get_workspaces $wm
        | from json 
        | get name
        | append $predefined
        | uniq
        | sort --ignore-case --natural)

    ($workspaces | str join "\n")
}

def get_workspaces [wm: string] {
    match $wm {
        'Hyprland' => (hyprctl workspaces -j),
        'sway' => (swaymsg -t get_workspaces -r)
    }
}

def get_current_wm [] {
    $env.XDG_CURRENT_DESKTOP
}
