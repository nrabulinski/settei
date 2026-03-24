{
  stdenv,
  cmake,
  pico-sdk,
  gcc-arm-embedded,
  python3,
  picotool,
}:

stdenv.mkDerivation {
  pname = "atx-extension-firmware";
  version = "0.1.0";

  src = ./.;

  strictDeps = true;
  enableParallelBuilding = true;

  nativeBuildInputs = [
    cmake
    gcc-arm-embedded
    python3
    picotool
  ];

  configurePhase = ''
    cmake \
      "-DPICO_SDK_PATH=${pico-sdk}/lib/pico-sdk" \
      "-DCMAKE_INSTALL_PREFIX=$out" \
      .
  '';

  buildPhase = "make -j$NIX_BUILD_CORES";

  installPhase = ''
    mkdir "$out"
    cp jetkvm-atx.uf2 "$out/"
  '';
}
