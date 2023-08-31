{lib, ...}: {
  options.assets = lib.mkOption {
    type = lib.types.unspecified;
  };

  config.assets = {
    sshKeys = import ./ssh.nix;
  };
}
