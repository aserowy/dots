#!/usr/bin/env nu

def main [user: string] {
    run-external "home-manager" "switch" "--flake" "~/src/dots/"
    run-external "nix-collect-garbage" "-d"

    let home =  $"/mnt/c/Users/($user)"
    let appdata = $"($home)/AppData"
    mkdir $"($home)/.config/"

    rm $"($home)/.config/starship.toml"
    cp ./home/components/starship/starship.toml $"($home)/.config/"

    let alacritty_path = $"($appdata)/Roaming/alacritty"
    rm -rfp $"($alacritty_path)"
    mkdir $"($alacritty_path)"
    sh -c $"cp -rL ~/.config/alacritty ($appdata)/Roaming"

    let nushell_path = $"($appdata)/Roaming/nushell"
    rm -rfp $"($nushell_path)"
    mkdir $"($nushell_path)"
    sh -c $"cp -rL ~/.config/nushell ($appdata)/Roaming"

    let nvim_path = $"($appdata)/Local/nvim/"
    rm -rfp $"($nvim_path)"
    mkdir $"($nvim_path)"
    sh -c $"cp -rL ~/.config/nvim ($appdata)/Local"
}
