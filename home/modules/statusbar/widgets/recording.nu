#!/usr/bin/env nu

def main [action: string] {
    if $action == 'status' {
        return (status)
    } else if $action == 'toggle' {
        return (toggle)
    }
}

def status [] {
    let is_running = (pgrep wf-recorder | lines | any {true})
    mut icon = "󰕧"
    if $is_running {
        $icon = "󰑋"
    }

    { "icon": $icon, "running": $is_running } | to json
}

def toggle [] {
    if (pgrep wf-recorder | lines | any {true}) {
        (pkill -SIGINT wf-recorder)

        while (pgrep wf-recorder | lines | any {true}) {
            sleep 1ms
        }
    } else {
        let area = (slurp -o)
        let date = (date now | format date "%Y-%m-%d_%H:%M:%S")
        let command = $"wf-recorder -g '($area)' -f ~/videos/($date).mp4"

        (hyprctl dispatch exec $command)

        while (pgrep wf-recorder | lines | is-empty) {
            sleep 1ms
        }
    }
}
