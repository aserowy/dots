{ config, pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      mkpasswd
    ];
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 2022 ];
      allowedUDPPorts = [ 53 ];
      allowPing = true;
    };
    useDHCP = false;
  };

  nix = {
    package = pkgs.nixVersions.stable;
    readOnlyStore = false;
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

  security.rtkit.enable = true;

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
        permitRootLogin = "no";
        passwordAuthentication = false;
      };
      ports = [ 2022 ];
    };
  };

  system = {
    # Did you read the comment?
    stateVersion = "21.05";

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

  time.timeZone = "Europe/Berlin";
}
