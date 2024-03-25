{
  lib,
  stdenv,
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
    with fenix;
    combine [
      stable.cargo
      stable.rustc
    ];
  crane' = crane.overrideToolchain rust;
  rocksdb' = rocksdb.overrideAttrs (
    final: prev: {
      version = "8.11.3";
      src = prev.src.override {
        rev = "v${final.version}";
        hash = "sha256-OpEiMwGxZuxb9o3RQuSrwZMQGLhe9xLT1aa3HpI4KPs=";
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
}
