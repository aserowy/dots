#!/usr/bin/env nu

def main [user: string] {
    run-external "home-manager" "switch" "--flake" "~/src/dots/"
    run-external "nix-collect-garbage" "-d"

    let home =  $"/mnt/c/Users/($user)"
    mkdir $"($home)/.config/"

    cp ./home/shell/headless/wezterm.lua $"($home)/.wezterm.lua"
    cp ./home/shell/headless/starship.toml $"($home)/.config/"

    # FIX: till carapace hits scoop
    # let nushell_path = $"($home)/AppData/Roaming/nushell"
    # mkdir $"($nushell_path)/scripts"
    # ---
    # cp ./home/shell/headless/nushell/* $"($nushell_path)/scripts"
    # cp ./home/shell/headless/nushell-env.nu $"($nushell_path)/env.nu"
    # cp ./home/shell/headless/nushell-config.nu $"($nushell_path)/config.nu"

    let nvim_path = $"($home)/AppData/Local/nvim"

    rm -p -r $"($nvim_path)/*"
    cp -r ~/.config/nvim/* $nvim_path
}
