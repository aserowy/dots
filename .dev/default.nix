{ pkgs, ... }: with pkgs; mkShell {
  buildInputs = [
    nil
    nixpkgs-fmt
    nodePackages.markdownlint-cli
    nodePackages.prettier
    nvfetcher
    stylua
    sumneko-lua-language-server
  ];
}
