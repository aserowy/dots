{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/root/.config/sops/age/keys.txt";

    secrets = {
      "gran/root_password" = {
        neededForUsers = true;
      };
      "homelab/root_password" = {
        neededForUsers = true;
      };
      "music/password" = {
        neededForUsers = true;
      };
      "music/root_password" = {
        neededForUsers = true;
      };
      "serowy/password" = {
        neededForUsers = true;
      };
      "k3s/cluster/token" = { };
    };
  };
}
