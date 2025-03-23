{
  projectRootFile = "nilla.nix";
  programs.deadnix.enable = true;
  programs.nixfmt.enable = true;
  programs.statix.enable = true;
  programs.fish_indent.enable = true;
  programs.deno.enable = true;
  programs.stylua.enable = true;
  programs.shfmt.enable = true;
  settings.global.excludes = [
    # agenix
    "*.age"

    # racket
    "*.rkt"
    "**/rashrc"

    # custom assets
    "*.png"
    "*.svg"
  ];
  settings.on-unmatched = "fatal";
}
