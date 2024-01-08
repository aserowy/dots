#!/usr/bin/env nu

def main [user: string] {
    run-external "home-manager" "switch" "--flake" "~/src/dots/"
    run-external "nix-collect-garbage" "-d"

    let home =  $"/mnt/c/Users/($user)"
    let appdata = $"($home)/AppData"
    mkdir $"($home)/.config/"

    rm $"($home)/.wezterm.lua"
    cp ~/.config/wezterm/wezterm.lua $"($home)/.wezterm.lua"
    cp ./home/components/starship/starship.toml $"($home)/.config/"

    let nushell_path = $"($appdata)/Roaming/nushell"
    rm -p -r $"($nushell_path)/*"
    cp ~/.config/nushell/* $nushell_path

    let nvim_path = $"($appdata)/Local/nvim/"
    rm -p -r $"($nvim_path)"
    mkdir $"($nvim_path)"
    sh -c $"cp -rL ~/.config/nvim ($appdata)/Local"
}
