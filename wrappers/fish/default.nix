{
  lib,
  pkgs,
  ...
}: {
  # TODO: Fix once https://github.com/viperML/wrapper-manager/issues/14 is resolved
  wrappers.fish = {
    basePackage = pkgs.runCommandNoCC "fish-binary" {} ''
      install -D -m555 ${lib.getExe pkgs.fish} "$out/bin/fish"
    '';
    extraWrapperFlags = "--inherit-argv0";

    prependFlags = let
      extraPkgs = with pkgs; [eza bat];
      # Can't use pathAdd because fish used as login shell will ignore the variables the wrapper sets up
      path-add-lines =
        lib.concatMapStringsSep "\n"
        (pkg: "fish_add_path --path --prepend '${lib.getExe' pkg ""}'")
        extraPkgs;
      config-fish = pkgs.writeText "config.fish" ''
        ${path-add-lines}
        source ${./config.fish}
      '';
    in [
      "-C"
      "source ${config-fish}"
    ];
  };
}
