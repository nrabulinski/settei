{pkgs, ...}: {
  programs.helix = {
    enable = true;
    settings = {
      theme = "base16_default_dark";
      editor = {
        true-color = true;
        line-number = "relative";
        mouse = false;
        cursor-shape.insert = "bar";
        color-modes = true;
        cursorline = true;
        auto-save = true;
        indent-guides.render = true;
      };
    };
    languages = {
      language = [
        {
          name = "koka";
          scope = "scope.koka";
          file-types = ["kk"];
          roots = [];
          indent = {
            tab-width = 4;
            unit = "    ";
          };
        }
        {
          name = "racket";
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
      ];
    };
  };

  wrappers.helix.pathAdd = [pkgs.nil];
}
