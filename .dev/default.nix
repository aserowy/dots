{ pkgs, ... }: with pkgs; mkShell {
  buildInputs = [
    deno
    doas-sudo-shim
    nil
    nixpkgs-fmt
    nodejs_20
    nodePackages.prettier
    stylua
    sumneko-lua-language-server
  ];
}
