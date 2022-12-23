{ pkgs, ... }: with pkgs; mkShell {
  buildInputs = [
    nodePackages.markdownlint-cli
    nodePackages.prettier
    nvfetcher
    stylua
    sumneko-lua-language-server
    rnix-lsp
  ];
  shellHook = ''
    # format
    alias fmt="prettier --write README.md && nixpkgs-fmt ."

    alias hms="home-manager switch --flake ~/src/dots/"
    alias nrs="nixos-rebuild switch --use-remote-sudo --flake ."

    # update wezterm config
    alias uw="cp ./shell/headless/wezterm.lua /mnt/c/Users/serowy/.wezterm.lua && cp ./shell/headless/alacritty.yml /mnt/c/Users/serowy/AppData/Roaming/alacritty/alacritty.yml"
  '';
}
