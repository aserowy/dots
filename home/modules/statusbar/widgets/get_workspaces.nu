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
    (hyprctl workspaces -j
        | from json
        | where id > 0 and monitorID == $monitor
        | select id name
        | sort-by name
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
