{ pkgs, ... }: with pkgs; mkShell {
  buildInputs = [
    deno
    nil
    nixpkgs-fmt
    # FIX: https://github.com/NixOS/nixpkgs/issues/249962
    # nvfetcher
    stylua
    sumneko-lua-language-server
  ];
}
