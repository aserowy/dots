{ config, pkgs, ... }:
{
  imports = [
    ../programs/git.nix
    ../programs/ssh.nix
  ];
}
