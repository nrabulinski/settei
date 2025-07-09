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
  wrapper-manager = import inputs.wrapper-manager-hm-compat {
    wrapper-manager = (import inputs.wrapper-manager).lib;
    inherit (inputs) home-manager;
  };
  wrappedPerSystem = lib.attrs.generate systems (
    system:
    wrapper-manager {
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
