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
    all-packages = wrapped.config.build.packages;
    base-packages = pkgs.symlinkJoin {
      name = "settei-base";
      paths = with all-packages; [
        rash
        helix
      ];
    };
  in {
    packages =
      all-packages
      // {
        inherit base-packages;
      };
  };
}
