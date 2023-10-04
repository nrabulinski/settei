{lib, ...}: {
  imports = [
    ../../shared/common
    ./hercules.nix
  ];

  system.stateVersion = "22.05";

  # https://github.com/NixOS/nixpkgs/issues/254807
  boot.swraid.enable = false;

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  settei.user.config = {
    services.ssh-agent.enable = true;
  };
}
