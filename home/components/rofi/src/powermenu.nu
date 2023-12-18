#!/usr/bin/env nu

let wm_all = 'all'
let wm_hypr = 'Hyprland'
let wm_sway = 'sway'

let commands = [
    [name wm command];
    ["  suspend" $wm_all 'systemctl suspend']
    ["⏻  shutdown" $wm_all 'systemctl poweroff']
    ["  reboot" $wm_all 'systemctl reboot']
]

def main [command_name: string = ''] {
    let current_wm = (get_current_wm)
    let valid_commands = ($commands
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
        
        (sh -c $command | ignore)
    }
}

def get_current_wm [] {
    $env.XDG_CURRENT_DESKTOP
}
