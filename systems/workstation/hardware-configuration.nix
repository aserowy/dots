{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "xhci_pci"
      "firewire_ohci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sr_mod"
    ];
    initrd.kernelModules = [
      "amdgpu"
      "dm-snapshot"
      "i915"
    ];
    kernelModules = [ "kvm-intel" ];
    # NOTE: reduces cracking audio on dac, see
    # https://discourse.nixos.org/t/setting-up-pipewire-to-get-rid-of-cracks-noises/56358
    kernelParams = [ "preempt=full" ];
    extraModulePackages = [ ];
    # NOTE: allows compiling aarch64-linux with qemu
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    # NOTE: prevents: Mount point '/boot' which backs the random seed file is world accessible,
    # which is a security hole!
    options = [
      "fmask=0077"
      "dmask=0077"
      "defaults"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
      enable32Bit = true;
    };
  };
}
