#!/usr/bin/env nu

let wm_all = 'all'
let wm_sway = 'sway'
let wm_i3 = 'i3'

let predefined = [
    [name wm command];
    ["⏻  shutdown" $wm_all 'systemctl poweroff']
    ["  reboot" $wm_all 'systemctl reboot']
    ["  suspend" $wm_all 'systemctl suspend']
    ["  lock" $wm_i3 'dm-tool lock']
    ["  logout" $wm_i3 'i3-msg exit']
    ["  logout" $wm_sway 'swaymsg exit']
]

def main [command_name: string = ''] {
    let current_wm = (get_current_wm)
    let valid_commands = ($predefined
        | where wm == $current_wm or wm == $wm_all)

    if $command_name == '' {
        ($valid_commands
            | get name
            | str join "\n")
    } else {
        let command = ($valid_commands
            | where name == $command_name
            | first
            | get command)
        
        run-external --redirect-stdout --redirect-stderr 'sh' '-c' $command | ignore
    }
}

def get_current_wm [] {
    if 'WAYLAND_DISPLAY' in $env {
        $wm_sway
    } else {
        $wm_i3
    }
}
