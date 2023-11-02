{
  configurations.nixos.ude = {
    config,
    modulesPath,
    lib,
    ...
  }: {
    imports = [
      "${modulesPath}/profiles/qemu-guest.nix"
      ./disks.nix
    ];

    nixpkgs.hostPlatform = "aarch64-linux";

    boot = {
      loader.systemd-boot.enable = true;
      loader.systemd-boot.configurationLimit = 1;
      loader.efi.canTouchEfiVariables = true;
    };

    common.hercules.enable = true;
    services.hercules-ci-agent.settings.concurrentTasks = 6;

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
