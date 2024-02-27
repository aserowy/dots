revision: { ... }: {
  services.nix-daemon.enable = true;

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

  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    casks = [ "google-chrome" "microsoft-edge" "obsidian" "spotify" "wezterm" ];
  };
}
