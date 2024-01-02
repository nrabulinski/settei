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
}: let
  crane' = crane.overrideToolchain fenix.stable.toolchain;
in
  crane'.buildPackage {
    inherit src;
    strictDeps = true;

    nativeBuildInputs = [rustPlatform.bindgenHook];

    buildInputs = lib.optionals stdenv.isDarwin [libiconv darwin.apple_sdk.frameworks.Security];

    # Use system RocksDB
    ROCKSDB_INCLUDE_DIR = "${rocksdb}/include";
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
  }
