{ pkgs, ... }:
let
  # FIX: till https://github.com/NixOS/nixpkgs/issues/334852 got merged
  clamav = pkgs.clamav.overrideAttrs (old: rec {
    version = "1.4.0";
    src = pkgs.fetchurl {
      url = "https://www.clamav.net/downloads/production/${old.pname}-${version}.tar.gz";
      hash = "sha256-1nqymeXKBdrT2imaXqc9YCCTcqW+zX8TuaM8KQM4pOY=";
    };
  });
in
{
  imports = [
    ../shared/base.nix
    ../shared/printing.nix

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
      nerdfonts
    ];
  };

  networking.hostName = "workstation";

  nixpkgs = {
    config = {
      # FIX: remove this once packages are updated
      permittedInsecurePackages = [
        "electron-27.3.11"
      ];
    };
  };

  programs = {
    seahorse.enable = true;
    steam.enable = true;
  };

  services = {
    clamav = {
      package = clamav;
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

    modules = {
      gtk.enable = true;
      tuigreet = {
        enable = true;
        command = "niri-session";
        # command = "Hyprland";
        # command = "sway";
      };
      xdg.enable = true;
    };

    onedrive.enable = true;

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
