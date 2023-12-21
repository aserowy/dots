#!/usr/bin/env nu

def main [launch: string] {
    let killed = (pkill --echo rofi)
    if $killed != "" {
        sleep 50ms
    }

    let monitor = (hyprctl activeworkspace -j | from json | get monitorID)
    let dashboard = $"dashboard_monitor_($monitor)"
    (eww open --config ~/.config/eww/sidebar/ $dashboard)

    (~/.config/rofi/launch.nu $launch "-run-command \"hyprctl dispatch exec '{cmd}'\"")

    (eww close --config ~/.config/eww/sidebar/ $dashboard)
}
