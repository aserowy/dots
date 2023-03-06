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
  '';
}
