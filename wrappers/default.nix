{ inputs, ... }:
{
  perSystem =
    { pkgs, inputs', ... }:
    let
      wrapped = inputs.wrapper-manager-hm-compat.lib {
        inherit pkgs;
        modules = [
          # ./starship
          ./helix
          # TODO: Enable again
          # ./rash
          ./fish
          ./wezterm
        ];
        specialArgs = {
          inherit inputs inputs';
        };
      };
      all-packages = wrapped.config.build.packages;
    in
    {
      packages = all-packages;
    };
}
