#!/usr/bin/env nu

def main [action: string] {
    if ($action | str contains "member=open") {
        let monitor = (get_current_monitor_id)
        (eww open --config . dashboard_monitor --screen $monitor)
    } else {
        (eww close --config . dashboard_monitor)
    }
}

def get_current_wm [] {
    $env.XDG_CURRENT_DESKTOP
}

def get_current_monitor_id [] {
    let wm = (get_current_wm)
    match $wm {
        'Hyprland' => { (hyprctl activeworkspace -j | from json | get monitorID) },
        'sway' => {
            let outputs = (swaymsg -r -t get_outputs | from json)
            for $it in $outputs --numbered {
                if ($it.item.focused == true) {
                    return $it.index
                }
            }
            return 0
        }
    }
}
