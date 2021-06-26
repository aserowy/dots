{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.acpi
  ];
}
