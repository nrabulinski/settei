{ config, ... }:
{
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ it87 ];
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    kernelModules = [
      "kvm-amd"
      "i2c-dev"
      "it87"
    ];
    extraModprobeConfig = ''
      options it87 ignore_resource_conflict=1
    '';
  };

  services.smartd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
}
