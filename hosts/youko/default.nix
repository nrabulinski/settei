{
  configurations.nixos.youko = {
    imports = [
      ./disks.nix
      ./hardware.nix
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };

    networking.networkmanager.enable = true;

    settei.user.config =
      { lib, ... }:
      {
        programs.git.signing = lib.mkForce {
          key = null;
          signByDefault = false;
        };
      };
  };
}
