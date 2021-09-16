with import <nixpkgs> { };
mkShell rec {
  name = "nix";
  buildInputs = [
    pkgs.nixpkgs-fmt
    pkgs.nodePackages.markdownlint-cli
    pkgs.nodePackages.prettier
  ];
  shellHook = ''
    # format
    alias fmt="prettier --write README.md && nixpkgs-fmt ."

    # update wezterm config
    alias wu="cp ./programs/wezterm/wezterm.lua /mnt/c/Users/serow/.wezterm.lua"
  '';
}
