#!/usr/bin/env nu

let predefined = [
    [name command];
    [drun 'rofi -config ~/.config/rofi/config.rasi -modi drun -show drun']
    [move 'rofi -config ~/.config/rofi/list.rasi -modi move:~/.config/rofi/move_by_name.nu -show move']
    [power 'rofi -config ~/.config/rofi/powermenu.rasi -modi power:~/.config/rofi/powermenu.nu -show power']
    [workspace 'rofi -config ~/.config/rofi/list.rasi -modi workspace:~/.config/rofi/focus_by_name.nu -show workspace']
]

def main [command_name: string] {
    let command = ($predefined
        | where name == $command_name
        | first
        | get command)

    run-external --redirect-stdout --redirect-stderr 'sh' '-c' $command | ignore
}

