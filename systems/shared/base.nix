{ pkgs, ... }:
{
  imports = [
    ../modules
  ];

  boot = {
    readOnlyNixStore = false;
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
      allowedTCPPorts = [ 80 443 2022 ];
      allowedUDPPorts = [ 53 ];
      allowPing = false;
    };
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

    # don’t shutdown when power button is short-pressed
    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      ports = [ 2022 ];
    };
  };

  system = {
    # Did you read the comment?
    stateVersion = "21.05";
  };

  time.timeZone = "Europe/Berlin";

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
    };
  };
}
