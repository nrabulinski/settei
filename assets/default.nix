{lib, ...}: {
  options.assets = lib.mkOption {
    type = lib.types.unspecified;
    readOnly = true;
  };

  config.assets = {
    sshKeys = import ./ssh.nix;
  };
}
