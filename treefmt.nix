{
  projectRootFile = "nilla.nix";
  programs.deadnix.enable = true;
  programs.nixfmt.enable = true;
  programs.statix.enable = true;
  programs.fish_indent.enable = true;
  programs.deno.enable = true;
  programs.stylua.enable = true;
  programs.shfmt.enable = true;
  programs.taplo.enable = true;
  programs.rustfmt.enable = true;
  settings.global.excludes = [
    # agenix
    "*.age"

    # custom assets
    "*.png"
    "*.svg"

    "**/.gitignore"
  ];
  settings.on-unmatched = "fatal";
}
