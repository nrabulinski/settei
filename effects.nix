{
  config,
  lib,
  withSystem,
  ...
}: {
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
        pin-cache = withSystem config.defaultEffectSystem ({
          pkgs,
          hci-effects,
          ...
        }: let
          collectDrvs = prefix: attrs: let
            drvs = lib.pipe attrs [
              (lib.filterAttrs (_: lib.isDerivation))
              (lib.mapAttrsToList (name: drv: {
                name = "${prefix}.${name}";
                inherit drv;
              }))
            ];
            recursed = lib.pipe attrs [
              (lib.filterAttrs (_: val:
                  (!lib.isDerivation val) && (lib.isAttrs val) && (val.recurseForDerivations or true)))
              (lib.mapAttrsToList (name: collectDrvs "${prefix}.${name}"))
            ];
          in
            drvs ++ (lib.flatten recursed);
          collected = collectDrvs "packages" herculesCI.config.onPush.default.outputs.packages;
          cachixCommands =
            lib.concatMapStringsSep
            "\n"
            ({
              name,
              drv,
            }: "cachix pin nrabulinski ${lib.escapeShellArg name} ${lib.escapeShellArg drv}")
            collected;
        in
          hci-effects.runIf (herculesCI?branch && herculesCI.branch == "main") (hci-effects.mkEffect {
            secretsMap."cachix-token" = "cachix-token";
            inputs = [pkgs.cachix];
            userSetupScript = ''
              cachix authtoken $(readSecretString cachix-token .token)
            '';
            # Discarding the context is fine here because we don't actually want to build those derivations.
            # They have already been built as part of this job,
            # we only want to pin them to make sure cachix doesn't GC them.
            effectScript = builtins.unsafeDiscardStringContext cachixCommands;
          }));
      };
    };
  };
}
