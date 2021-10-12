{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    acpi
    bottom
  ];
}
