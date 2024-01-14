{
  lib,
  stdenvNoCC,
  requireFile,
  fetchurl,
  undmg,
  makeWrapper,
  edition ? "personal",
  versionsJson ? ./versions.json,
}:
let
  versions = lib.importJSON versionsJson;

  fetchVersion =
    {
      private,
      version,
      edition,
      sha256,
      suffix,
    }:
    let
      fetcher = if private then requireFile else fetchurl;
    in
    fetcher {
      name = "BinaryNinja-${edition}-${version}.${suffix}";
      url =
        if private then
          "https://binary.ninja/recover/"
        else
          "https://cdn.binary.ninja/installers/BinaryNinja-${edition}.${suffix}";
      inherit sha256;
    };

  binaries = lib.mapAttrs (
    version: editions:
    lib.mapAttrs (edition: files: {
      aarch64-darwin = fetchVersion {
        inherit (files) private;
        inherit version edition;
        suffix = "dmg";
        sha256 = files.macos;
      };
      x86_64-darwin = fetchVersion {
        inherit (files) private;
        inherit version edition;
        suffix = "dmg";
        sha256 = files.macos;
      };
    }) editions
  ) versions;

  platformAttrs = {
    linux = throw "TODO";
    darwin = {
      nativeBuildInputs = [
        undmg
        makeWrapper
      ];

      sourceRoot = ".";
      installPhase = ''
        mkdir -p "$out/"{Applications,bin}
        cp -r *.app "$out/Applications"
        makeWrapper \
          "$out/Applications/Binary Ninja.app/Contents/MacOS/binaryninja" \
          "$out/bin/binaryninja"
      '';
    };
  };
  platformAttrs' =
    if stdenvNoCC.isDarwin then
      platformAttrs.darwin
    else if stdenvNoCC.isLinux then
      platformAttrs.linux
    else
      throw "Unsupported system";

  base = finalAttrs: {
    pname = "binary-ninja-${edition}";
    version = "3.5.4526";

    src = binaries.${finalAttrs.finalPackage.version}.${edition}.${stdenvNoCC.system};

    meta = with lib; {
      homepage = "https://binary.ninja/";
      mainProgram = "binaryninja";
      license = licenses.unfree;
      platforms = platforms.darwin ++ [ "x86_64-linux" ];
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
in
stdenvNoCC.mkDerivation (finalAttrs: platformAttrs' // (base finalAttrs))
