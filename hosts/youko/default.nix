{
  configurations.nixos.youko =
    { config, username, ... }:
    {
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

      age.secrets.niko-pass.file = ../../secrets/youko-niko-pass.age;
      users.users.${username}.hashedPasswordFile = config.age.secrets.niko-pass.path;
    };
}