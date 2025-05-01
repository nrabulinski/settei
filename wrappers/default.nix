{
  lib,
  config,
  inputs,
}:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  wrappedPerSystem = lib.attrs.generate systems (
    system:
    inputs.wrapper-manager-hm-compat.lib {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [
        ./starship
        ./helix
        # TODO: Enable again
        # ./rash
        ./fish
        ./wezterm
      ];
      specialArgs = { inherit inputs; };
    }
  );
  wrappedPerSystem' = builtins.mapAttrs (_: wrapped: wrapped.config.build.packages) wrappedPerSystem;
  wrapperNames = builtins.attrNames wrappedPerSystem'."x86_64-linux";
in
{
  config.packages = lib.attrs.generate wrapperNames (wrapper: {
    inherit systems;
    builder = "custom-load";
    package = { system }: wrappedPerSystem'.${system}.${wrapper};
  });
}
