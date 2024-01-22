{
  pkgs,
  lib,
  inputs',
  ...
}: {
  services.skhd = {
    enable = true;
    skhdConfig = let
      spaceCount = 6;
      spaceBindings =
        lib.genList
        (i: let num = toString (i + 1); in "cmd - ${num} : yabai -m space --focus ${num}")
        spaceCount;
    in ''
      cmd - return : ${pkgs.alacritty}/Applications/Alacritty.app/Contents/MacOS/alacritty
      cmd + shift - return : ${inputs'.niko-nur.packages.qutebrowser-bin}/Applications/qutebrowser.app/Contents/MacOS/qutebrowser

      cmd - h : yabai -m window --focus west
      cmd - j : yabai -m window --focus south
      cmd - k : yabai -m window --focus north
      cmd - l : yabai -m window --focus east

      cmd + shift - h : yabai -m window --swap west
      cmd + shift - j : yabai -m window --swap south
      cmd + shift - k : yabai -m window --swap north
      cmd + shift - l : yabai -m window --swap east

      cmd + shift - space : yabai -m window --toggle float

      ${lib.concatStringsSep "\n" spaceBindings}
    '';
  };
}
