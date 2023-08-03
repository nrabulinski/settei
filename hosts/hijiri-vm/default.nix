{
  self,
  inputs,
  config,
  ...
}: {
  configurations.nixos.hijiri-vm = {
    modulesPath,
    lib,
    username,
    ...
  }: {
    imports = [
      "${modulesPath}/profiles/qemu-guest.nix"
      (import ./disks.nix {})
    ];
    boot = {
      supportedFilesystems = ["btrfs"];
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };

    nixpkgs.system = "aarch64-linux";

    users.users.${username}.openssh.authorizedKeys.keys = lib.attrValues config.assets.sshKeys.user;

    networking.domain = "hijiri";
    networking.hostName = "vm";
  };
}
