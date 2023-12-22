#!/usr/bin/env nu

let predefined = [
    [name command];
    [drun 'rofi -config ~/.config/rofi/config.rasi -modi drun -show drun']
    [move 'rofi -config ~/.config/rofi/list.rasi -modi move:~/.config/rofi/move_by_name.nu -show move']
    [power 'rofi -config ~/.config/rofi/powermenu.rasi -modi power:~/.config/rofi/powermenu.nu -show power']
    [rename 'rofi -config ~/.config/rofi/list.rasi -modi rename:~/.config/rofi/rename.nu -show rename']
    [workspace 'rofi -config ~/.config/rofi/list.rasi -modi workspace:~/.config/rofi/focus_by_name.nu -show workspace']
]

def main [command_name: string, additional_rofi_flags: string = ""] {
    mut command = ($predefined
        | where name == $command_name
        | first
        | get command)

    if $additional_rofi_flags != "" {
        $command = $command + " " + $additional_rofi_flags
    }

    (dbus-send --type=signal /org/freedesktop/Notifications com.github.ibonn.rofi.open)
    (sh -c $command | ignore)
    (dbus-send --type=signal /org/freedesktop/Notifications com.github.ibonn.rofi.close)
}

