{
  pkgs,
  inputs',
  config,
  ...
}: {
  wrappers.rash = let
    readlinePatched = pkgs.fetchFromGitHub {
      owner = "nrabulinski";
      repo = "readline";
      rev = "8eb52c163d6ea7c3cec2cc6b1011ce00738942e1";
      hash = "sha256-1yU0ZUBQqYEn85j4T2pLs02MTyJnO5BbYALIa88iomY=";
    };
    racket-with-libs = inputs'.racket.packages.racket.newLayer {
      withRacketPackages = ps:
        with ps; [
          readline-gpl
          (readline-lib.override {
            src = "${readlinePatched}/readline-lib";
          })
          rash
          threading
          functional
          racket-langserver

          # TODO: Remove once dependency resolution is fixed
          slideshow-lib
          r5rs-lib
          data-enumerate-lib
          plot-lib
          plot-gui-lib
          plot-compat
          srfi-lib
          typed-racket-compatibility
          future-visualizer-pict
          macro-debugger-text-lib
          profile-lib
          images-gui-lib
        ];
      buildInputs = with pkgs; [readline];
    };
  in {
    basePackage = pkgs.writeShellScriptBin "rash" ''
      exec "${racket-with-libs}/bin/rash-repl" "$@"
    '';
    env.XDG_CONFIG_HOME = {
      value = pkgs.linkFarm "rash-config" {
        "rash/rashrc" = ./rashrc;
        "rash/rashrc.rkt" = ./rashrc.rkt;
      };
      force = true;
    };
    pathAdd = [
      racket-with-libs
      config.wrappers.starship.wrapped
    ];
  };
}
