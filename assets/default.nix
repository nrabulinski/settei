{ lib }:
{
  options.assets = lib.options.create {
    type = lib.types.raw;
    writable = false;
  };

  config.assets = {
    sshKeys = import ./ssh.nix;
  };
}
