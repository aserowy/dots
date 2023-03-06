#!/usr/bin/env nu

def main [user: string] {
    run-external "home-manager" "switch" "--flake" "~/src/dots/"

    let home =  $"/mnt/c/Users/($user)"

    cp ../home/shell/headless/wezterm.lua $"($home)/.wezterm.lua"

    let nushell_path = $"($home)/AppData/Roaming/nushell"
    cp -r ../home/shell/headless/nushell $"($nushell_path)/scripts"
    cp ../home/shell/headless/nushell-env.nu $"($nushell_path)/env.nu"
    cp ../home/shell/headless/nushell-config.nu $"($nushell_path)/config.nu"
}
