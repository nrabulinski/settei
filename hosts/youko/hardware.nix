{
  boot = {
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
    ];
  };

  services.smartd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
}
