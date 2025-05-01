{ perInput }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.settei.flake-qol;

  nixpkgsInputToFlakeRef =
    input:
    if input._type or "" == "flake" then
      {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        inherit (input) lastModified narHash rev;
      }
    else
      input;
in
{
  _file = ./flake-qol.nix;

  options.settei.flake-qol = with lib; {
    enable = mkEnableOption "QoL defaults when using flakes" // {
      default = true;
    };
    reexportAsArgs = mkOption {
      type = types.bool;
      default = true;
    };
    inputs = mkOption { type = types.unspecified; };
    nixpkgsRef = mkOption {
      type = types.unspecified;
      default = cfg.inputs.nixpkgs;
      apply =
        ref: if builtins.isString ref then builtins.parseFlakeRef ref else nixpkgsInputToFlakeRef ref;
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

  config =
    let
      reexportedArgs = lib.mkIf cfg.reexportAsArgs { inherit (cfg) inputs inputs-flakes inputs'; };
    in
    lib.mkIf cfg.enable {
      settei.flake-qol = {
        inputs-flakes = lib.filterAttrs (_: input: input ? flake -> input.flake) cfg.inputs;
        inputs' = lib.mapAttrs (_: perInput pkgs.stdenv.system) cfg.inputs-flakes;
      };

      _module.args = reexportedArgs;
      settei.user.extraArgs = reexportedArgs;

      nix = {
        registry.nixpkgs.to = cfg.nixpkgsRef;
        nixPath = [ "nixpkgs=flake:nixpkgs" ];
      };
    };
}
