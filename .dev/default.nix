{ pkgs, ... }: with pkgs; mkShell {
  buildInputs = [
    deno
    doas-sudo-shim
    nil
    nixpkgs-fmt
    nodejs_20
    nodePackages.prettier
    nodePackages.vscode-json-languageserver
    nufmt
    stylua
    sumneko-lua-language-server
        taplo
  ];
}
