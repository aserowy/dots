{ config, pkgs, ... }:
{
  home.file.".config/eww/" = {
    recursive = true;
    source = ./eww;
  };

  home.packages = with pkgs; [
    eww
  ];

  systemd.user.services.eww = {
    Unit = {
      Description = "a bar display";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecPrestart = "${pkgs.coreutils}/bin/mkfifo /tmp/ewwpipe";
      ExecStart = "${pkgs.eww}/bin/eww daemon";
      ExecStop = "${pkgs.eww}/bin/eww kill";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
