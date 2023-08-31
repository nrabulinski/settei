{
  config,
  self,
  ...
}: {
  configurations.nixos.kazuki = {
    modulesPath,
    lib,
    username,
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

    users.users.${username}.openssh.authorizedKeys.keys = lib.attrValues config.assets.sshKeys.user;

    boot = {
      supportedFilesystems = ["btrfs"];
      loader.systemd-boot.enable = true;
      loader.systemd-boot.configurationLimit = 1;
      loader.efi.canTouchEfiVariables = true;
    };
  };
}
