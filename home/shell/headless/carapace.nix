{ pkgs, ... }:
{
  home.packages = with pkgs; [
    carapace
  ];

  home = {
    file.".config/carapace/specs/g.yaml".source = ./carapace/g-spec.yml;
  };
}
