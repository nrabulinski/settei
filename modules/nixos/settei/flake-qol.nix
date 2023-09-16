{perInput}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.settei.flake-qol;
in {
  _file = ./flake-qol.nix;

  options.settei.flake-qol = with lib; {
    enable = mkEnableOption "QoL defaults when using flakes";
    reexportAsArgs = mkOption {
      type = types.bool;
      default = true;
    };
    inputs = mkOption {
      type = types.unspecified;
    };
    inputs-flakes = mkOption {
      type = types.attrs;
      readOnly = true;
    };
    inputs' = mkOption {
      type = types.attrs;
      readOnly = true;
    };
  };

  config = let
    reexportedArgs = lib.mkIf cfg.reexportAsArgs {
      inherit (cfg) inputs inputs-flakes inputs';
    };
  in
    lib.mkIf cfg.enable {
      settei.flake-qol = {
        inputs-flakes = lib.filterAttrs (_: input: input ? flake -> input.flake) cfg.inputs;
        inputs' = lib.mapAttrs (_: perInput pkgs.stdenv.system) cfg.inputs-flakes;
      };

      _module.args = reexportedArgs;
      settei.user.extraArgs = reexportedArgs;

      nix = {
        registry = lib.mapAttrs (_: flake: {inherit flake;}) cfg.inputs-flakes;
        nixPath = map (name: "${name}=flake:${name}") (lib.attrNames cfg.inputs-flakes);
      };
    };
}
