{
  config.systems.nixos.hijiri.module =
    {
      modulesPath,
      username,
      config,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        ./disks.nix
      ];

      boot.initrd.availableKernelModules = [
        "uas"
        "sdhci_pci"
      ];
      boot.kernelParams = [ "apple_dcp.show_notch=1" ];

      nixpkgs.hostPlatform = "aarch64-linux";
      hardware.asahi.enable = true;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = false;

      age.secrets.niko-pass.file = ../../../secrets/hijiri-niko-pass.age;
      users.users.${username}.hashedPasswordFile = config.age.secrets.niko-pass.path;

      networking.networkmanager.enable = true;

      services.udisks2.enable = true;
      settei.incus.enable = true;

      # TODO: Persist blanking configuration
      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };
      services.udev.extraRules = ''
        KERNEL=="macsmc-battery", SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}="80", ATTR{charge_control_start_threshold}="70"
      '';

      boot.extraModprobeConfig = ''
        options hid_apple fnmode=2 swap_opt_cmd=1 iso_layout=1
      '';

      # TODO: Download the firmware dynamically instead
      hardware.asahi.peripheralFirmwareDirectory = ./firmware;
    };
}
