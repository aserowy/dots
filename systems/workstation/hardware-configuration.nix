{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    # FIX: remove override and use the default kernel > Kernel versions 6.9rc-5+/6.8.9+/6.6.30+ have a DRM bug which results in unplayable crashes
    # https://gitlab.freedesktop.org/drm/amd/-/issues/3343
    kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_latest.override {
      argsOverride = rec {
        src = pkgs.fetchurl {
          url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
          sha256 = "sha256-HEzcudVg+tH7ldssuK++3JIvnq2Eg3H+QDY7E/n2Mbo=";
        };
        version = "6.8.8";
        modDirVersion = "6.8.8";
      };
    });

    initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ "amdgpu" "dm-snapshot" "i915" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
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

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    opengl = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
