{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    docker-compose
  ];
}
