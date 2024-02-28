#!/usr/bin/env nu

def main [action: string] {
    if ($action | str contains "member=open") {
        let monitor = (hyprctl activeworkspace -j | from json | get monitorID)
        let dashboard = $"dashboard_monitor_($monitor)"

        (eww open --config . $dashboard)
    } else {
        (eww active-windows -c .)
            | lines
            | where {|it| $it | str contains "dashboard_monitor_"}
            | each {|row|
                let split_index = ($row | str index-of ':')
                let target = ($row | str substring 0..$split_index)
                return $target
            }
            | each {|row| (eww close --config . $row)}
    }
}
