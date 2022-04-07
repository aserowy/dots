{ pkgs, users, ... }:
{
  imports = [
    ./serowy.nix
  ]; 

  users = {
    users.serowy = {
      extraGroups = [
        "docker"
      ];
    };
  };
}
