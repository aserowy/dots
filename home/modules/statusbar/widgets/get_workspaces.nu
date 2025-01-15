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
        'niri' => {
            let current_monitor = (niri msg --json focused-output | from json | get name)
            (niri msg --json workspaces
                | from json
                # | where output == $monitor and active_window_id != null
                | where active_window_id != null
                | insert on_current_output {|rw| $rw.output == $current_monitor}
                | select id idx is_focused on_current_output
                | update idx {|row| $row.idx | into string }
                | rename id name focused on_current_output
            )
        }
        _ => []
    }
}
