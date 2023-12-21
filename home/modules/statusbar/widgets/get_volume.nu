#!/usr/bin/env nu

let volume_icons = [
    [threshold icon];
    [0 "󰖁"]
    [0.2 ""]
    [0.5 "󰖀"]
    [0.8 "󰕾"]
]

def main [] {
    let output = (wpctl get-volume @DEFAULT_AUDIO_SINK@)

    let muted = $output | str contains "MUTED"
    let volume = $output | split row " " | get 1 | into float
    let icon = get_icon $volume $muted

    { "icon": $icon, "volume": $volume, "muted": $muted } | to json
}

def get_icon [volume: float, muted: bool] {
     if $muted {
         return "󰝟" 
     }

     let icon = $volume_icons
        | where threshold <= $volume
        | last

    return $icon.icon
}
