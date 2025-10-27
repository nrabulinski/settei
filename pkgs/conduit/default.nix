{
  src,
  rocksdb,
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

  cargoHash = "sha256-kWurvPo1hjDAFIpfHHOw78ngAVgArW2iYKCB6VscDqw=";

  nativeBuildInputs = [ rustPlatform.bindgenHook ];

  # Use system RocksDB
  ROCKSDB_INCLUDE_DIR = "${rocksdb}/include";
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";
  NIX_OUTPATH_USED_AS_RANDOM_SEED = "randomseed";
  CONDUIT_VERSION_EXTRA = src.shortRev;
}
