{ pkgs, ... }:
{
  imports = [
    ../shared/base.nix
    ../shared/printing.nix
    ../shared/sops.nix

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # INFO: sets ozone wayland support for all chromium based applications
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      inter
      powerline-fonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };

  networking.hostName = "workstation";

  programs = {
    seahorse.enable = true;
    steam.enable = true;
  };

  services = {
    clamav = {
      updater.enable = true;

      daemon = {
        enable = true;
        settings = {
          ExcludePath = "^/home/serowy/.local/share/Steam\nExcludePath ^/home/serowy/.steam";
        };
      };
    };

    # lsblk --discard to ensure ssd supports trim
    # (disc-gran and disc-max should be non zero)
    fstrim.enable = true;

    fwupd.enable = true;

    gnome.gnome-keyring.enable = true;

    # don’t shutdown when power button is short-pressed
    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

    modules = {
      gtk.enable = true;
      tuigreet = {
        enable = true;
        command = "niri-session";
      };
      xdg.enable = true;
    };

    onedrive.enable = true;

    openssh.settings.PermitRootLogin = "no";

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
    };

    # to enable working with qmk on this pc
    udev.packages = [ pkgs.qmk-udev-rules ];

    xserver.videoDrivers = [ "amdgpu" ];
  };

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = "github:aserowy/dots";
      flags = [
        "--recreate-lock-file"
        "--no-write-lock-file"
        "-L"
      ];
      dates = "03:45";
    };
  };

  system = {
    # Did you read the comment?
    stateVersion = "21.05";
  };

  systemd = {
    network = {
      enable = true;
      networks."10-lan" = {
        matchConfig.Name = "eno1";
        networkConfig.DHCP = "ipv4";
      };
    };

    # TODO: lutris specific, but unable to set with home manager?
    user.extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';
  };
}
