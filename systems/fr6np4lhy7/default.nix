revision:
{ ... }:
{
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
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
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
      "windows-app"
    ];
  };

  programs.zsh.enable = true;

  system = {
    primaryUser = "alexander.serowy";

    defaults = {
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
  };
}
