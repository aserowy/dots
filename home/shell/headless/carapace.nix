{ pkgs, ... }:
{
  home.packages = with pkgs; [
    carapace
  ];

  home = {
    file.".config/carapace/specs/gt.yaml".source = ./carapace/gt-spec.yml;
  };
}
