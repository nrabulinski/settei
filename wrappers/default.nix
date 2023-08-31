{inputs, ...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    argsModule = {
      _module.args = {
        inherit inputs';
        inherit inputs;
      };
    };
    wrapped = inputs.wrapper-manager.lib {
      inherit pkgs;
      modules = [
        inputs.wrapper-manager-hm-compat.wrapperManagerModules.homeManagerCompat
        argsModule
        ./starship
        ./helix
        ./rash
      ];
    };
  in {
    inherit (wrapped.config.build) packages;
  };
}
