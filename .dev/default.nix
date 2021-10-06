{ pkgs, ... }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nvfetcher
  ];
}
