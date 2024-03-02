revision: { ... }: {
  nix.settings.experimental-features = "nix-command flakes";

  system = {
    configurationRevision = revision;
    stateVersion = 4;
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users."alexander.serowy" = {
    name = "alexander.serowy";
    home = "/Users/alexander.serowy";
  };

  homebrew = {
    enable = true;
    casks = [ "google-chrome" "microsoft-edge" "obsidian" "spotify" "wezterm" ];
  };

  programs.zsh.enable = true;

  services = {
    nix-daemon.enable = true;

    yabai = {
      enable = true;
    };
  };

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "left";
      show-recents = false;
      showhidden = true;
      static-only = true;
      tilesize = 32;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  };
}
