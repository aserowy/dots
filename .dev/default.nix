{ pkgs, ... }: with pkgs; mkShell {
  buildInputs = [
    nodePackages.markdownlint-cli
    nodePackages.prettier
    nvfetcher
    stylua
    sumneko-lua-language-server
    nil
  ];
}
