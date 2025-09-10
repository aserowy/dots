{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "xhci_pci"
    "firewire_ohci"
    "usb_storage"
    "sd_mod"
  ];

  # NOTE: We need to add "cryptd" as one of our kernel modules, or else the system won't be booted expecting an encrypted partition, which is where our root, swap, (and home) logical volumes resides in.
  boot.initrd.kernelModules = [
    "dm-snapshot"
    "cryptd"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    graphics.enable = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

      modesetting.enable = true;
      nvidiaSettings = true;
      open = false;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
    };
  };
}
