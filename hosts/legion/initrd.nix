{
  config,
  username,
  ...
}: {
  boot.initrd = {
    availableKernelModules = ["ath10k_pci" "r8169"];
    network.enable = true;
    network.ssh = {
      enable = true;
      authorizedKeys = config.users.users.${username}.openssh.authorizedKeys.keys;
    };
  };
}
