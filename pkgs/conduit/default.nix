{
  lib,
  stdenv,
  pkgs,
  system,
  fenix,
  crane,
  src,
  libiconv,
  rocksdb,
  darwin,
  rustPlatform,
}:
let
  rust =
    with fenix.${system};
    combine [
      stable.cargo
      stable.rustc
    ];
  crane' = (crane pkgs).overrideToolchain rust;
  rocksdb' = rocksdb.overrideAttrs (
    final: prev: {
      version = "9.1.1";
      src = prev.src.override {
        rev = "v${final.version}";
        hash = "sha256-/Xf0bzNJPclH9IP80QNaABfhj4IAR5LycYET18VFCXc=";
      };
    }
  );
in
crane'.buildPackage {
  inherit src;
  strictDeps = true;

  nativeBuildInputs = [ rustPlatform.bindgenHook ];

  buildInputs = lib.optionals stdenv.isDarwin [
    libiconv
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  # Use system RocksDB
  ROCKSDB_INCLUDE_DIR = "${rocksdb'}/include";
  ROCKSDB_LIB_DIR = "${rocksdb'}/lib";
  NIX_OUTPATH_USED_AS_RANDOM_SEED = "randomseed";
  CONDUIT_VERSION_EXTRA = src.shortRev;
}
