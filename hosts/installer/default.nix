{ lib, ... }:
{
  configurations.nixos =
    let
      mkInstaller =
        system:
        (
          { pkgs, ... }:
          {
            nixpkgs = {
              inherit system;
            };

            environment.systemPackages = [ pkgs.nixos-install-tools ];

            # Make nixos-anywhere treat this as a installer iso
            system.nixos.variant_id = "installer";
          }
        );
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      installers = map (system: lib.nameValuePair "installer-${system}" (mkInstaller system)) systems;
    in
    lib.listToAttrs installers;
}
