{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "settei-ddns";
  version = "0.0.1";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
}
