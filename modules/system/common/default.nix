{isLinux}: {
  config,
  configurationName,
  lib,
  pkgs,
  inputs',
  username,
  ...
}: let
  inherit (inputs'.settei.packages) fish;
  sharedConfig = {
    settei.user.config = {
      programs.git = {
        enable = true;
        difftastic.enable = true;
        lfs.enable = true;
        userName = "Nikodem Rabuliński";
        userEmail = lib.mkDefault "nikodem@rabulinski.com";
        signing = {
          key = config.settei.sane-defaults.allSshKeys.${configurationName};
          signByDefault = true;
        };
        extraConfig = {
          gpg.format = "ssh";
          push.followTags = true;
        };
      };

      programs.fish.enable = true;
    };

    programs.fish.enable = true;
    environment.shells = [fish];
    users.users.${username}.shell = fish;

    # NixOS' fish module doesn't allow setting what package to use for fish,
    # so I need to override the fish package.
    nixpkgs.overlays = [(_: _: {inherit fish;})];
  };

  linuxConfig = lib.optionalAttrs isLinux {
    system.stateVersion = "22.05";

    # https://github.com/NixOS/nixpkgs/issues/254807
    boot.swraid.enable = false;

    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    settei.user.config = {
      services.ssh-agent.enable = true;
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    system.stateVersion = 4;
  };
in {
  _file = ./default.nix;

  imports = [
    (import ./hercules.nix {inherit isLinux;})
  ];

  config = lib.mkMerge [
    sharedConfig
    linuxConfig
    darwinConfig
  ];
}
