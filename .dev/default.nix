{ nixidy, pkgs, ... }: with pkgs; mkShell {
  buildInputs = [
    doas-sudo-shim
    kubectl
    nil
    nixidy.packages.${pkgs.system}.default
    nixpkgs-fmt
    nodejs_20
    nodePackages.prettier
    nodePackages.vscode-json-languageserver
    nufmt
    sops
    stylua
    sumneko-lua-language-server
    taplo
  ];
}
