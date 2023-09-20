# TODO: Potentially make this a common module?
{
  pkgs,
  config,
  username,
  ...
}: let
  mail = "alert@nrab.lol";
  aliases = pkgs.writeText "mail-aliases" ''
    ${username}: nikodem@rabulinski.com
    root: ${mail}
  '';
in {
  age.secrets.alert-plaintext.file = ../../secrets/alert-plain-pass.age;

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      inherit aliases;
      tls = "on";
      auth = "login";
      tls_starttls = "off";
    };
    accounts = {
      default = {
        host = "mail.nrab.lol";
        passwordeval = "cat ${config.age.secrets.alert-plaintext.path}";
        user = mail;
        from = mail;
      };
    };
  };
}
