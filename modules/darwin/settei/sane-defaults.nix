# For sane-default options shared between NixOS and darwin, see modules/shared/settei/sane-defaults.nix
{
  config,
  lib,
  username,
  ...
}: {
  config = lib.mkIf config.settei.sane-defaults.enable {
    services.nix-daemon.enable = true;

    security.pam.enableSudoTouchIdAuth = true;

    users.users.${username}.home = "/Users/${username}";
  };
}
