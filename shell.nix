with import <nixpkgs> { };
mkShell rec {
  name = "nix";
  buildInputs = [
    pkgs.nodePackages.markdownlint-cli
    pkgs.nodePackages.prettier
    pkgs.stylua
    pkgs.sumneko-lua-language-server
    pkgs.rnix-lsp
  ];
  shellHook = ''
    # format
    alias fmt="prettier --write README.md && nixpkgs-fmt ."

    # update wezterm config
    alias uw="cp ./shell/headless/wezterm.lua /mnt/c/Users/serowy/.wezterm.lua && cp ./shell/headless/alacritty.yml /mnt/c/Users/serowy/AppData/Roaming/alacritty/alacritty.yml"
  '';
}
