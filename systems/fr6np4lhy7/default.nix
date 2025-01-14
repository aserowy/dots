revision:
{ ... }:
{
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
    casks = [
      "drawio"
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

  services = {
    nix-daemon.enable = true;
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

    finder.FXPreferredViewStyle = "clmv";

    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  };
}
