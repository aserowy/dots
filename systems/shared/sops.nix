{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/root/.config/sops/age/keys.txt";

    secrets = {
      "root/password" = {
        neededForUsers = true;
      };
      "serowy/password" = {
        neededForUsers = true;
      };
      "k3s/cluster/token" = { };
    };
  };
}
