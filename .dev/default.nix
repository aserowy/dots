{ pkgs, ... }: with pkgs; mkShell {
  buildInputs = [
    deno
    nil
    nixpkgs-fmt
    nodejs_20
    nodePackages.prettier
    nvfetcher
    stylua
    sumneko-lua-language-server
  ];
}
