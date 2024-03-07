{ lib, pkgs, ... }:
{
  wrappers.fish = {
    basePackage = pkgs.fish;
    wrapByDefault = false;

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

              source ${./prompt.fish}
              source ${./config.fish}
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
        ];
      };
  };
}
