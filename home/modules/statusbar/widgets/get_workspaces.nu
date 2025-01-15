#!/usr/bin/env nu

let workspace_icons = [
    [name icon];
    ["dots" "󰟒"]
    ["focused" "󰪥"]
    ["gaming" "󰖹"]
    ["notes" "󰛿"]
    ["social" "󰀉"]
    ["urgent" "󰵚"]
    ["work" "󰸥"]
]

def main [monitor: number = 0] {
    let workspaces = get_workspaces $monitor
    if ($workspaces | is-empty) {
        return '[]'
    }

    ($workspaces
        | sort-by --ignore-case --natural name id
        | insert icon {|rw| icon $rw.name}
        | to json -r
        | print
    )
}

def icon [name: string] {
    let icon = $workspace_icons
        | where name == $name
        | append {name: "default" icon: "󰝥"}
        | first

    return $icon.icon
}

def get_current_wm [] {
    $env.XDG_CURRENT_DESKTOP
}

def get_workspaces [monitor: number] {
    let wm = (get_current_wm)
    match $wm {
        'Hyprland' => (hyprctl workspaces -j
            | from json
            | where monitorID == $monitor
            # FIX: add focused to workspace item hyprctl activeworkspace may be
            # usefull if focused is not part of response
            | select id name
        ),
        # TODO: from number to output to filter workspaces if desired
        # let outputs = (swaymsg -r -t get_outputs | from json)
        # for $it in $outputs --numbered { ... $it.index == $monitor ...
        'sway' => (swaymsg -r -t get_workspaces
            | from json
            | select id name focused
        )
        # {"id":5,"idx":3,"name":"dots","output":"DP-2","is_active":true,"is_focused":true,"active_window_id":33},
        # {"id":6,"idx":4,"name":null,"output":"DP-2","is_active":false,"is_focused":false,"active_window_id":15},
        # {"id":2,"idx":2,"name":null,"output":"HDMI-A-1","is_active":true,"is_focused":false,"active_window_id":7},
        'niri' => (niri msg --json workspaces
            | from json
            # | where output == $monitor and active_window_id != null
            | where active_window_id != null
            | select id idx is_focused
            | update idx {|row| $row.idx | into string }
            | rename id name focused
        )
        _ => []
    }
}
