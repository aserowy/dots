{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ardour
    gparted
    remmina
    teams

    (runCommandLocal "i3-config-link" { } ''
      dest="$HOME/.config/i3/config"
      existing=$(readlink "$dest")
      if [ $? -eq 1 ]; then
        ln -s /etc/i3/config "$dest" && mkdir -p $out && touch $out/done.txt
      else
        if [[ "$existing" == /nix/store/* ]]; then
          ln -fs /etc/i3/config "$dest" && mkdir -p $out && touch $out/done.txt
        else
          echo "Existing symlink is $existing, refusing to overwrite"
          exit 1
        fi
      fi
    '')
  ];

  imports = [
    ../shared/gtk.nix
    ../shared/onedrive.nix
    ../shared/vscode.nix
  ];
}
