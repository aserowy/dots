#!/usr/bin/env nu

def main [action: string] {
    if ($action | str contains "member=open") {
        let monitor = (hyprctl activeworkspace -j | from json | get monitorID)
        let dashboard = $"dashboard_monitor_($monitor)"

        (eww open --config . $dashboard)
    } else {
        (eww windows -c .)
            | lines
            | where {|it| $it | str contains "*dashboard_monitor_"}
            | each {|row| $row | str substring 1..}
            | each {|row| (eww close --config . $row)}
    }
}
