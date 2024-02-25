{
  config,
  lib,
  withSystem,
  self,
  ...
}:
let
  collectFlakeOutputs =
    { config, pkgs }:
    let
      inherit (pkgs) lib;
      collectDrvs =
        prefix: attrs:
        let
          drvs = lib.pipe attrs [
            (lib.filterAttrs (_: lib.isDerivation))
            (lib.mapAttrsToList (
              name: drv: {
                name = lib.concatStringsSep "." (prefix ++ [ name ]);
                inherit drv;
              }
            ))
          ];
          recursed = lib.pipe attrs [
            (lib.filterAttrs (
              _: val: (!lib.isDerivation val) && (lib.isAttrs val) && (val.recurseForDerivations or true)
            ))
            (lib.mapAttrsToList (name: collectDrvs (prefix ++ [ name ])))
          ];
        in
        drvs ++ (lib.flatten recursed);
      rootOutputs = builtins.removeAttrs config.onPush.default.outputs [ "effects" ];
    in
    collectDrvs [ ] rootOutputs;
in
{
  defaultEffectSystem = "aarch64-linux";

  hercules-ci = {
    flake-update = {
      enable = true;
      when.dayOfWeek = "Mon";
    };
  };

  herculesCI = herculesCI: {
    onPush.default = {
      outputs.effects = {
        pin-cache = withSystem config.defaultEffectSystem (
          { pkgs, hci-effects, ... }:
          let
            collected = collectFlakeOutputs {
              inherit (herculesCI) config;
              inherit pkgs;
            };
            cachixCommands =
              lib.concatMapStringsSep "\n"
                ({ name, drv }: "cachix pin nrabulinski ${lib.escapeShellArg name} ${lib.escapeShellArg drv}")
                collected;
          in
          hci-effects.runIf (herculesCI.config.repo.branch == "main") (
            hci-effects.mkEffect {
              secretsMap."cachix-token" = "cachix-token";
              inputs = [ pkgs.cachix ];
              userSetupScript = ''
                cachix authtoken $(readSecretString cachix-token .token)
              '';
              # Discarding the context is fine here because we don't actually want to build those derivations.
              # They have already been built as part of this job,
              # we only want to pin them to make sure cachix doesn't GC them.
              effectScript = builtins.unsafeDiscardStringContext cachixCommands;
            }
          )
        );
      };
    };
  };

  perSystem =
    { pkgs, lib, ... }:
    rec {
      legacyPackages.outputsList =
        let
          config = self.herculesCI {
            primaryRepo = { };
            herculesCI = { };
          };
        in
        collectFlakeOutputs { inherit config pkgs; };

      legacyPackages.github-matrix =
        let
          systems = lib.groupBy ({ drv, ... }: drv.system) legacyPackages.outputsList;
        in
        lib.concatMapStringsSep "\n"
          (
            { name, value }:
            ''
              ${name}=${builtins.toJSON (map (d: d.name) value)}
            ''
          )
          (lib.attrsToList systems);
    };
}
