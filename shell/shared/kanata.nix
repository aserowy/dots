{ pkgs, ... }:
{
  environment = {
    etc."kanata.kbd".source = ./kanata.kbd;

    systemPackages = with pkgs; [
      kanata
    ];
  };

  hardware.uinput.enable = true;

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
    description = "kanata keyboard remapper";
    documentation = [ "https://github.com/jtroo/kanata" ];
    # Environment=PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin
    # Environment=DISPLAY=:0
    # Environment=HOME=/path/to/home/folder
    environment = {
      DISPLAY = ":0";
    };
    serviceConfig = {
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg /etc/kanata.kbd";
      Type = "simple";
      Restart = "no";
    };
    wantedBy = [ "default.target" ];
  };
}
