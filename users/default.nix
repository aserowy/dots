{ config, lib, ... }:
with lib;

let
  cnfg = config.users;
in
{
  imports = [
    ./root.nix

    ./gran.nix
    ./music.nix
    ./serowy.nix
    ./sim.nix
  ];

  options.users = {
    enable = mkEnableOption "user configuration";

    setMutableUsers = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cnfg.enable {
    users.mutableUsers = cnfg.setMutableUsers;
  };
}
