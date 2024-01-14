{
  lib,
  pkgs,
  ...
}: {
  # TODO: Fix once https://github.com/viperML/wrapper-manager/issues/14 is resolved
  wrappers.fish = let
    inherit (pkgs) runCommandNoCC;
  in {
    basePackage = runCommandNoCC "fish-binary" {} ''
      install -D -m555 ${lib.getExe pkgs.fish} "$out/bin/fish"
    '';
    extraWrapperFlags = "--inherit-argv0";

    prependFlags = let
      # Can't use pathAdd because fish used as login shell will ignore the variables the wrapper sets up
      config-fish = runCommandNoCC "config.fish" { inherit (pkgs) bat eza; } ''
        substituteAll ${./config.fish} "$out"
      '';
    in [
      "-C"
      "source ${config-fish}"
    ];
  };
}
