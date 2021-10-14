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
    alias wu="cp ./programs/wezterm.lua /mnt/c/Users/serow/.wezterm.lua"
    alias wuy="cp ./programs/wezterm.lua /mnt/c/Users/serowy/.wezterm.lua"
  '';
}
