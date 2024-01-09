{lib, pkgs, ...}: {
  # TODO: Fix once https://github.com/viperML/wrapper-manager/issues/14 is resolved
  wrappers.fish = {
    basePackage = pkgs.runCommandNoCC "fish-binary" {} ''
      install -D -m555 ${lib.getExe pkgs.fish} "$out/bin/fish"
    '';

    prependFlags = [
      "-C"
      "source ${./config.fish}"
    ];

    pathAdd = with pkgs; [bat eza];
  };
}
