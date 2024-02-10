{
  configurations.nixos.kazuki = {
    config,
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
      ./storage.nix
      ./attic.nix
    ];

    nixpkgs.hostPlatform = "aarch64-linux";
    # Not intended for interactive use
    settei.user.enable = false;

    boot = {
      loader.systemd-boot.enable = true;
      loader.systemd-boot.configurationLimit = 1;
      loader.efi.canTouchEfiVariables = true;
    };

    common.hercules.enable = true;
    common.github-runner = {
      enable = true;
      runners.settei = {
        url = "https://github.com/nrabulinski/settei";
        instances = 2;
      };
    };
  };
}
