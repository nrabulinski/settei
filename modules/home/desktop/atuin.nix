{
  programs.atuin = {
    enable = true;
    daemon.enable = true;
    flags = [
      "--disable-up-arrow"
      "--disable-ctrl-r"
    ];
    settings = {
      keymap_mode = "vim-insert";
    };
  };

  programs.fish.interactiveShellInit = ''
    bind / _atuin_search
  '';
}
