{ pkgs, ... }:
{
  imports = [
    ../shared/base.nix
    ../shared/printing.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        # FIX: remove after new disko configuration got applied
        configurationLimit = 1;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  hardware.openrazer.enable = true;
  environment.systemPackages = with pkgs; [
    openrazer-daemon
    polychromatic
  ];

  environment.sessionVariables = {
    # INFO: sets ozone wayland support for all chromium based applications
    NIXOS_OZONE_WL = "1";
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      inter
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      powerline-fonts
    ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
  };

  networking = {
    hostName = "workstation";
    firewall.allowPing = false;
  };

  programs = {
    dconf.enable = true;

    # NOTE: Configs are handled in user space
    niri.enable = true;

    seahorse.enable = true;
    steam = {
      enable = true;
      protontricks.enable = true;
    };
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

    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };

    # NOTE: lsblk --discard to ensure ssd supports trim
    # (disc-gran and disc-max should be non zero)
    fstrim.enable = true;

    fwupd.enable = true;

    logind.settings.Login = {
      HandlePowerKey = "suspend";
    };

    modules = {
      gtk.enable = true;
      sddm = {
        enable = true;
        session = "niri";
        theme = "hyprland_kath";
      };
    };

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

    # NOTE: to enable working with qmk on this pc
    # udev.packages = [ pkgs.qmk-udev-rules ];

    xserver.videoDrivers = [ "amdgpu" ];
  };

  system.stateVersion = "21.05";

  systemd = {
    network = {
      enable = true;
      networks."10-lan" = {
        matchConfig.Name = "enp130s0";
        networkConfig.DHCP = "ipv4";
      };
    };

    user.extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';
  };
}
