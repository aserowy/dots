#!/usr/bin/env nu

def main [user: string] {
    run-external "home-manager" "switch" "--flake" "~/src/dots/"
    run-external "nix-collect-garbage" "-d"

    let home =  $"/mnt/c/Users/($user)"
    let appdata = $"($home)/AppData"
    mkdir $"($home)/.config/"

    rm $"($home)/.wezterm.lua"
    cp ~/.config/wezterm/wezterm.lua $"($home)/.wezterm.lua"

    rm $"($home)/.config/starship.toml"
    cp ./home/components/starship/starship.toml $"($home)/.config/"

    rm -rf $"($appdata)/Roaming/alacritty"
    mkdir $"($appdata)/Roaming/alacritty"
    cp ./home/components/alacritty/alacritty.toml $"($appdata)/Roaming/alacritty/alacritty.toml"

    let nushell_path = $"($appdata)/Roaming/nushell"
    rm -p -r $"($nushell_path)/*"
    cp ~/.config/nushell/* $nushell_path

    let nvim_path = $"($appdata)/Local/nvim/"
    rm -p -r $"($nvim_path)"
    mkdir $"($nvim_path)"
    sh -c $"cp -rL ~/.config/nvim ($appdata)/Local"
}
