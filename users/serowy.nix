{ pkgs, users, ... }:
{
  users = {
    users.serowy = {
      createHome = true;
      extraGroups = [
        "audio"
        "disk"
        "networkmanager"
        "video"
        "wheel"
      ];
      group = "users";
      home = "/home/serowy";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoChM+zDcZalCCTTF4NTeNyBcrbLBs8b0vBTp/EW1nX serowy" ];
      shell = pkgs.zsh;
      uid = 1000;
    };
  };
}
