{ lib, pkgs, ... }:
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
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  environment = {
    # INFO: sets ozone wayland support for all chromium based applications
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      discord
      drawio
      ghostty
      gimp-with-plugins
      google-chrome
      insync
      kdePackages.plasma-browser-integration
      onlyoffice-desktopeditors
      spotify

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
    hostName = "sims";
    interfaces = {
      enp0s31f6.useDHCP = lib.mkDefault true;
      wlan0.useDHCP = lib.mkDefault true;
    };
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    wireless = {
      iwd.enable = true;
      userControlled.enable = true;
    };
  };

  programs = {
    steam.enable = true;
  };

  console = {
    earlySetup = true;
    # NOTE: ensure the keyboard layout is set correctly on login screen
    useXkbConfig = true;
  };

  services = {
    clamav = {
      updater.enable = true;

      daemon = {
        enable = true;
        settings = {
          ExcludePath = "^/home/sims/.local/share/Steam\nExcludePath ^/home/sims/.steam";
        };
      };
    };

    desktopManager.plasma6.enable = true;

    displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    # lsblk --discard to ensure ssd supports trim
    # (disc-gran and disc-max should be non zero)
    fstrim.enable = true;

    fwupd.enable = true;

    # don’t shutdown when power button is short-pressed
    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

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
