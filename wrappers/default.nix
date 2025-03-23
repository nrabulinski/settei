{ lib, config }:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  wrappedPerSystem = lib.attrs.generate systems (
    system:
    config.inputs.wrapper-manager-hm-compat.result.lib {
      pkgs = config.inputs.nixpkgs.result.legacyPackages.${system};
      modules = [
        ./starship
        ./helix
        # TODO: Enable again
        # ./rash
        ./fish
        ./wezterm
      ];
      specialArgs.inputs = builtins.mapAttrs (_: input: input.result) config.inputs;
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
