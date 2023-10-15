#!/usr/bin/env nu

let predefined = [
    [name command];
    [drun 'rofi -config /etc/rofi/config.rasi -modi drun -show drun']
    [move 'rofi -config /etc/rofi/list.rasi -modi move:/etc/rofi/move_by_name.nu -show move']
    [power 'rofi -config /etc/rofi/powermenu.rasi -modi power:/etc/rofi/powermenu.nu -show power']
    [workspace 'rofi -config /etc/rofi/list.rasi -modi workspace:/etc/rofi/focus_by_name.nu -show workspace']
]

def main [command_name: string] {
    let command = ($predefined
        | where name == $command_name
        | first
        | get command)

    run-external --redirect-stdout --redirect-stderr 'sh' '-c' $command | ignore
}

