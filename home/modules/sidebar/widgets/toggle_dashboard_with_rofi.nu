#!/usr/bin/env nu

def main [action: string] {
    if ($action | str contains "member=open") {
        let monitor = (hyprctl activeworkspace -j | from json | get monitorID)
        (eww open --config . dashboard_monitor --screen $monitor)
    } else {
        (eww close --config . dashboard_monitor)
    }
}
