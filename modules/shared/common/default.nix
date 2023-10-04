{
  config,
  configurationName,
  lib,
  ...
}: {
  settei.user.config = {
    programs.git = {
      enable = true;
      difftastic.enable = true;
      lfs.enable = true;
      userName = "Nikodem Rabuliński";
      userEmail = lib.mkDefault "nikodem@rabulinski.com";
      signing = {
        key = config.settei.sane-defaults.allSshKeys.${configurationName};
        signByDefault = true;
      };
      extraConfig = {
        gpg.format = "ssh";
        push.followTags = true;
      };
    };
  };
}
