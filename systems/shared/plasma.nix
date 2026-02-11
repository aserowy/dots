{ pkgs, ... }:
{
  imports = [
    ./base.nix
    ./printing.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  environment = {
    # INFO: sets ozone wayland support for all chromium based applications
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      brave
      ghostty
      git
      neovim
      onedrivegui
      yeet

      kdePackages.discover
      kdePackages.dragon
      kdePackages.isoimagewriter
      kdePackages.kcalc
      kdePackages.kcharselect
      kdePackages.kclock
      kdePackages.kcolorchooser
      kdePackages.kolourpaint
      kdePackages.ksystemlog
      kdePackages.kwallet
      kdePackages.kwalletmanager
      kdePackages.partitionmanager
      kdePackages.plasma-browser-integration
      kdePackages.sddm-kcm
      kdiff3
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
    firewall.allowPing = false;

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
      daemon.enable = true;
    };

    desktopManager.plasma6.enable = true;

    displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        autoNumlock = true;
        wayland.enable = true;
      };
    };

    flatpak.enable = true;

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

    xserver.xkb.layout = "de";
  };

  system.stateVersion = "21.05";

  systemd = {
    user.extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';

    # NOTE: adds flathub as flatpak repo for all users
    services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
