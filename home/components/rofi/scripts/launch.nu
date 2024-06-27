#!/usr/bin/env nu

let predefined = [
    [name command];
    [drun 'rofi -modi drun -show drun']
    [move 'rofi -modi move:~/.config/rofi/move_by_name.nu -show move']
    [power 'rofi -modi power:~/.config/rofi/powermenu.nu -show power']
    [rename 'rofi -modi rename:~/.config/rofi/rename.nu -show rename']
    [workspace 'rofi -modi workspace:~/.config/rofi/focus_by_name.nu -show workspace']
]

# TODO: add capability to pass themes to rofi
def main [command_name: string, additional_rofi_flags: string = ""] {
    if (pgrep rofi | lines | any {true}) {
        (pkill rofi)

        while (pgrep rofi | lines | any {true}) {
            sleep 1ms
        }
    }

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

