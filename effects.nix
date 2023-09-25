{lib, ...}: {
  defaultEffectSystem = "aarch64-linux";

  hercules-ci = {
    flake-update = {
      enable = true;
      when.dayOfWeek = "Mon";
    };
  };

  # TODO: Remove once I set up a macOS server
  herculesCI.ciSystems = lib.mkForce [
    "x86_64-linux"
    "aarch64-linux"
  ];
}
