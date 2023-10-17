{ modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices =
    [
      { device = "/dev/disk/by-label/swap"; }
    ];
}
