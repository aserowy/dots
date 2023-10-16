#!/usr/bin/env nu

def main [user: string] {
    run-external "home-manager" "switch" "--flake" "~/src/dots/"
    run-external "nix-collect-garbage" "-d"

    let home =  $"/mnt/c/Users/($user)"
    mkdir $"($home)/.config/"

    cp ./home/modules/wezterm/wezterm.lua $"($home)/.wezterm.lua"
    cp ./home/modules/nushell/starship.toml $"($home)/.config/"

    let nushell_path = $"($home)/AppData/Roaming/nushell"
    mkdir $"($nushell_path)/scripts"

    cp ./home/modules/nushell/nushell-env.nu $"($nushell_path)/env.nu"
    cp ./home/modules/nushell/nushell-config.nu $"($nushell_path)/config.nu"

    let nvim_path = $"($home)/AppData/Local/nvim"

    rm -p -r $"($nvim_path)/*"
    cp -r ~/.config/nvim/* $nvim_path
}
