{
  config,
  lib,
  pkgs,
  ...
}:
let
  setteiStarship = config.wrappers.starship.wrapped;
in
{
  wrappers.fish = {
    basePackage = pkgs.fish;

    programs.fish =
      { config, ... }:
      {
        extraWrapperFlags = "--inherit-argv0";

        prependFlags =
          let
            # Can't rely on pathAdd because fish used as login shell will ignore the variables the wrapper sets up
            path-add-lines = lib.concatMapStringsSep "\n" (
              pkg: "fish_add_path --path --prepend '${lib.getExe' pkg ""}'"
            ) config.pathAdd;
            config-fish = pkgs.writeText "config.fish" ''
              ${path-add-lines}

              source ${./config.fish}
              source ${./greeting.fish}
            '';
          in
          [
            "-C"
            "source ${config-fish}"
          ];

        pathAdd = with pkgs; [
          eza
          bat
          fzf
          ripgrep
          zoxide
          direnv
          fd
          file
          yazi
          setteiStarship
        ];
      };
  };
}
