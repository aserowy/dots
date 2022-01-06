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
    package = pkgs.nixFlakes;
    useSandbox = true;
    autoOptimiseStore = true;
    readOnlyStore = false;
    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "@wheel" ];
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
      permitRootLogin = "no";
      passwordAuthentication = false;
      ports = [ 2022 ];
    };

    # compose on right alt to be able to write äöüß
    xserver.xkbOptions = "compose:ralt";
  };

  system = {
    # Did you read the comment?
    stateVersion = "21.05";

    autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = "github:aserowy/nixos";
      flags = [
        "--recreate-lock-file"
        "--no-write-lock-file"
        "-L"
      ];
      dates = "daily";
    };
  };

  time.timeZone = "Europe/Berlin";
}
