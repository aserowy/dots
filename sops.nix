{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/root/.config/sops/age/keys.txt";

    secrets = {
      "music/password" = {
        neededForUsers = true;
      };
      "music/root_password" = {
        neededForUsers = true;
      };
      "serowy/password" = {
        neededForUsers = true;
      };
      "sim/password" = {
        neededForUsers = true;
      };
      "k3s/cluster/token" = { };
    };
  };
}
