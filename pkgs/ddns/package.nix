{ rustPlatform, lib }:
rustPlatform.buildRustPackage {
  pname = "settei-ddns";
  version = "0.0.1";
  src =
    with lib.fileset;
    toSource {
      root = ./.;
      fileset = unions [
        ./Cargo.lock
        ./Cargo.toml
        ./src
      ];
    };
  cargoLock.lockFile = ./Cargo.lock;
}
