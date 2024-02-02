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
        # ./starship
        ./helix
        # TODO: Enable again
        # ./rash
        ./fish
      ];
    };
    all-packages = wrapped.config.build.packages;

    fish-base = pkgs.fish;
    fish-wrapped = all-packages.fish;
    fish = pkgs.symlinkJoin {
      inherit (fish-base) name meta passthru;
      paths = [fish-wrapped fish-base];
    };
  in {
    packages =
      all-packages
      // {
        inherit fish;
      };
  };
}
