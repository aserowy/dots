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
        configurationLimit = 5;
      };
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

  networking.hostName = "sims";

  programs = {
    steam.enable = true;
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
    # fstrim.enable = true;

    fwupd.enable = true;

    # don’t shutdown when power button is short-pressed
    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

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
  };

  system = {
    # Did you read the comment?
    stateVersion = "21.05";
  };

  systemd = {
    network = {
      enable = true;
      networks."10-lan" = {
        matchConfig.Name = "enp130s0";
        networkConfig.DHCP = "ipv4";
      };
    };

    # TODO: lutris specific, but unable to set with home manager?
    user.extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';
  };
}
