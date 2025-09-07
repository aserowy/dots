{ lib, pkgs, ... }:
{
  imports = [
    ../shared/base.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      enableCryptodisk = true;
    };
  };

  console = {
    earlySetup = true;
    # NOTE: ensure the keyboard layout is set correctly on login screen
    useXkbConfig = true;
  };

  environment = {
    # INFO: sets ozone wayland support for all chromium based applications
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      ghostty
      git
      neovim
      yeet
    ];
  };

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

  i18n = {
    defaultLocale = "de_DE.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_COLLATE = "de_DE.UTF-8";
      LC_CTYPE = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MESSAGES = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  networking = {
    hostName = "musicstation";

    firewall.allowPing = false;

    interfaces = {
      enp5s2.useDHCP = lib.mkDefault true;
      wlan0.useDHCP = lib.mkDefault true;
    };
  };

  nixpkgs.config.nvidia.acceptLicense = true;

  programs = {
    steam.enable = true;
  };

  services = {
    clamav = {
      updater.enable = true;

      daemon = {
        enable = true;
      };
    };

    desktopManager.gnome.enable = true;

    displayManager = {
      defaultSession = "gnome";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    # lsblk --discard to ensure ssd supports trim
    # (disc-gran and disc-max should be non zero)
    fstrim.enable = true;

    fwupd.enable = true;

    logind.settings.Login = {
      HandlePowerKey = "suspend";
    };

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

    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb.layout = "de";
    };
  };

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      flake = "github:aserowy/dots";
      # no recreate-lock-file because updates are automated with gh actions
      flags = [
        "-L"
      ];
      dates = "weekly";
      randomizedDelaySec = "30min";
      fixedRandomDelay = true;
    };

    # Did you read the comment?
    stateVersion = "21.05";
  };

  systemd = {
    # TODO: lutris specific, but unable to set with home manager?
    user.extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';
  };
}
