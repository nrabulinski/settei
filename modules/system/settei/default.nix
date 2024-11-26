{
  perInput,
  # TODO: Figure out a nicer way of doing this without infrec?
  isLinux,
}:
{
  lib,
  pkgs,
  config,
  options,
  ...
}:
{
  _file = ./default.nix;

  imports = [
    (import ./sane-defaults.nix { inherit isLinux; })
    (import ./flake-qol.nix { inherit perInput; })
    ./user.nix
    (import ./programs { inherit isLinux; })
    (import ./tailscale.nix { inherit isLinux; })
    (import ./containers.nix { inherit isLinux; })
    ./unfree.nix
  ];

  options.settei = with lib; {
    username = mkOption { type = types.str; };
  };
}
