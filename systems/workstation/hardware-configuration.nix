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

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "ahci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];

    # NOTE: reduces cracking audio on dac, see
    # https://discourse.nixos.org/t/setting-up-pipewire-to-get-rid-of-cracks-noises/56358
    kernelParams = [ "preempt=full" ];

    extraModulePackages = [ ];

    # NOTE: allows compiling aarch64-linux with qemu
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    amdgpu = {
      initrd.enable = true;
      amdvlk.enable = true;
    };
  };
}
