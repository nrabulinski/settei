{
  lib,
  stdenv,
  src,
  libiconv,
  rocksdb,
  darwin,
  rustPlatform,
}:
let
  manifest = (builtins.fromTOML (builtins.readFile "${src}/Cargo.toml")).package;
in
rustPlatform.buildRustPackage {
  pname = manifest.name;
  inherit (manifest) version;

  inherit src;
  strictDeps = true;

  useFetchCargoVendor = true;
  cargoHash = "sha256-wESDxtKRMm/jyCr4kc20UuHGcE2s+OCMjfL+l1XihnA=";

  nativeBuildInputs = [ rustPlatform.bindgenHook ];

  buildInputs = lib.optionals stdenv.isDarwin [
    libiconv
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  # Use system RocksDB
  ROCKSDB_INCLUDE_DIR = "${rocksdb}/include";
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";
  NIX_OUTPATH_USED_AS_RANDOM_SEED = "randomseed";
  CONDUIT_VERSION_EXTRA = src.shortRev;
}
