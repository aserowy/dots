{ config, pkgs, ... }:
{
  environment = {
    etc."kanata.kbd".source = ./kanata.kbd;

    systemPackages = with pkgs; [
      kanata
    ];
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [ uinput ];

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  users = {
    groups.uinput = { };

    # TODO: user agnostic?
    users.serowy.extraGroups = [
      "input"
      "uinput"
    ];
  };

  systemd.user.services.kanata = {
    Unit = {
      Description = "kanata keyboard remapper";
      Documentation = "https://github.com/jtroo/kanata";
    };

    Service = {
      # Environment=PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin
      # Environment=DISPLAY=:0
      # Environment=HOME=/path/to/home/folder
      Environment = [ "DISPLAY=:0" ];
      Type = "simple";
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg /etc/kanata.kbd";
      Restart = "no";
    };

    Install = {
      WantedBy = "default.target";
    };
  };
}
