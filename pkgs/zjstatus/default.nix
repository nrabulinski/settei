{
  src,
  rust-overlay,
  extend,
  makeRustPlatform,
}:
let
  inherit (extend (import rust-overlay)) rust-bin;
  toolchain = rust-bin.stable.latest.minimal.override {
    targets = [ "wasm32-wasip1" ];
  };
  rustPlatform = makeRustPlatform {
    rustc = toolchain;
    cargo = toolchain;
  };
  manifest = (builtins.fromTOML (builtins.readFile "${src}/Cargo.toml")).package;
in
rustPlatform.buildRustPackage {
  pname = manifest.name;
  inherit (manifest) version;

  inherit src;
  strictDeps = true;

  doCheck = false;

  buildPhase = "cargo build -j$NIX_BUILD_CORES --offline --release";
  installPhase = "install -D -t $out target/wasm32-wasip1/release/zjstatus.wasm";

  cargoLock.lockFile = "${src}/Cargo.lock";
}
