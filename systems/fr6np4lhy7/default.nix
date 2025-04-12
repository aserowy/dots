revision:
{ ... }:
{
  # FIX: trace: warning: alexander.serowy profile: You have set either `nixpkgs.config` or `nixpkgs.overlays` while using `home-manager.useGlobalPkgs`. This will soon not be possible. Please remove all `nixpkgs` options when using `home-manager.useGlobalPkgs`. nix.settings.experimental-features = "nix-command flakes";

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
    casks = [
      "discord"
      "drawio"
      "epic-games"
      # "ghostty"
      "google-chrome"
      "microsoft-edge"
      "obsidian"
      "onedrive"
      "spotify"
      "steam"
    ];
  };

  programs.zsh.enable = true;

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "left";
      show-recents = false;
      showhidden = true;
      static-only = true;
      tilesize = 32;
    };

    finder.FXPreferredViewStyle = "clmv";

    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  };
}
