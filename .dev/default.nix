{ pkgs, ... }: with pkgs; mkShell {
  buildInputs = [
    deno
    nil
    nixpkgs-fmt
    nvfetcher
    stylua
    sumneko-lua-language-server
  ];
}
