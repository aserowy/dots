#!/usr/bin/env nu

def main [user: string] {
    run-external "home-manager" "switch" "--flake" "~/src/dots/"
    run-external "nix-collect-garbage" "-d"

    let home =  $"/mnt/c/Users/($user)"
    mkdir $"($home)/.config/"

    rm $"($home)/.wezterm.lua"
    cp ~/.config/wezterm/wezterm.lua $"($home)/.wezterm.lua"
    cp ./home/modules/nushell/starship.toml $"($home)/.config/"

    let nushell_path = $"($home)/AppData/Roaming/nushell"
    rm -p -r $"($nushell_path)/*"
    cp ~/.config/nushell/* $nushell_path

    let nvim_path = $"($home)/AppData/Local/nvim"
    rm -p -r $"($nvim_path)/*"
    cp -r ~/.config/nvim/* $nvim_path
}
