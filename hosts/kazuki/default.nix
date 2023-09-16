{
  config,
  self,
  ...
}: {
  configurations.nixos.kazuki = {
    modulesPath,
    lib,
    ...
  }: {
    imports = [
      "${modulesPath}/profiles/qemu-guest.nix"
      ./disks.nix

      ./conduit.nix
      ./mail.nix
      ./vault.nix
    ];

    nixpkgs.system = "aarch64-linux";

    boot = {
      loader.systemd-boot.enable = true;
      loader.systemd-boot.configurationLimit = 1;
      loader.efi.canTouchEfiVariables = true;
    };

    common.hercules.enable = true;
  };
}
