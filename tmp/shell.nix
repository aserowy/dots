with import <nixpkgs> { };
mkShell rec {
  name = "nix";
  buildInputs = [
    pkgs.nodePackages.markdownlint-cli
    pkgs.nodePackages.prettier
    pkgs.rnix-lsp
  ];
  shellHook = ''
  '';
}
