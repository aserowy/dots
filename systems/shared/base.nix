{ pkgs, ... }:
{
  imports = [
    ../modules
  ];

  boot = {
    tmp.cleanOnBoot = true;
  };

  environment = {
    defaultPackages = [ ];

    systemPackages = with pkgs; [
      acpi
      git
      mkpasswd
      smartmontools
    ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
  };

  networking = {
    firewall = {
      enable = true;
      allowPing = false;
    };
    nftables.enable = true;
    useDHCP = false;
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d --max-freed $((64 * 1024**3))";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    settings = {
      allowed-users = [ "@wheel" ];
      auto-optimise-store = true;
      sandbox = true;
      trusted-users = [ "@wheel" ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  programs.dconf.enable = true;

  security = {
    rtkit.enable = true;

    sudo.enable = false;
    doas.enable = true;
  };

  services = {
    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };

  time.timeZone = "Europe/Berlin";
}
