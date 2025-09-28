{
  perInput,
  # TODO: Figure out a nicer way of doing this without infrec?
  isLinux,
}:
{
  lib,
  pkgs,
  inputs',
  username,
  ...
}:
{
  _file = ./default.nix;

  imports = [
    (import ./sane-defaults.nix { inherit isLinux; })
    (import ./flake-qol.nix { inherit perInput; })
    ./user.nix
    (import ./tailscale.nix { inherit isLinux; })
    (import ./containers.nix { inherit isLinux; })
    ./unfree.nix
    (import ./github-runner.nix { inherit isLinux; })
    (import ./incus.nix { inherit isLinux; })
    (import ./monitoring.nix { inherit isLinux; })
    (import ./builder.nix { inherit isLinux; })
  ];

  options.settei = with lib; {
    username = mkOption {
      type = types.str;
      default = "niko";
    };
  };

  config = {
    programs.fish.enable = true;
    users.users.${username}.shell = pkgs.fish;

    time.timeZone = lib.mkDefault "Europe/Warsaw";

    # NixOS' fish module doesn't allow setting what package to use for fish,
    # so I need to override the fish package.
    nixpkgs.overlays = [ (_: _: { inherit (inputs'.settei.packages) fish; }) ];
  };
}
