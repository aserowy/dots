{ pkgs, ... }:
{
  environment = {
    etc."kanata.kbd".source = ./kanata.kbd;

    systemPackages = with pkgs; [
      kanata
    ];
  };

  hardware.uinput.enable = true;

  # TODO: user agnostic?
  users.users.serowy.extraGroups = [
    "input"
    "uinput"
  ];

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
