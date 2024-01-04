#!/usr/bin/env nu

def main [launch: string] {
    (~/.config/rofi/launch.nu $launch "-run-command \"hyprctl dispatch exec '{cmd}'\"")
}
