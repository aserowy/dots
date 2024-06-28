#!/usr/bin/env nu

def main [launch: string] {
    (~/.config/rofi/scripts/launch.nu $launch "-run-command \"hyprctl dispatch exec '{cmd}'\"")
}
