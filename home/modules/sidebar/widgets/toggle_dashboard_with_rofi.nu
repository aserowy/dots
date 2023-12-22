#!/usr/bin/env nu

def main [] {
    # FIX: replace while with 'wait for process start' maybe dbus-send??
    while true {
        if (pgrep rofi | lines | any {true}) {
            # NOTE: currently only implemented for hyprland
            let monitor = (hyprctl activeworkspace -j | from json | get monitorID)
            let dashboard = $"dashboard_monitor_($monitor)"

            (eww open --config . $dashboard)

            print "opened"

            while (pgrep rofi | lines | any {true}) {
                sleep 25ms
            }

            let dashboard_opened = (eww windows -c .
                | lines
                | where {|it| $it
                    | str contains $"*($dashboard)"
                }
                | any {true}
            )

            if $dashboard_opened {
                (eww close --config . $dashboard)

                print "closed"
            }
        }

        sleep 100ms
    }
}
