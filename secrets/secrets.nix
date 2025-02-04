let
  keys = import ../assets/ssh.nix;
in
{
  "leet-nrab-lol-pass.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "alert-nrab-lol-pass.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  # "bitwarden-env-file.age".publicKeys = [keys.system.kazuki keys.other.bootstrap];
  "hercules-token.age".publicKeys = [
    keys.system.kazuki
    keys.system.ude
    keys.system.kogata
    keys.other.bootstrap
  ];
  "hercules-cache.age".publicKeys = [
    keys.system.kazuki
    keys.system.ude
    keys.system.kogata
    keys.other.bootstrap
  ];
  "hercules-secrets.age".publicKeys = [
    keys.system.kazuki
    keys.system.ude
    keys.system.kogata
    keys.other.bootstrap
  ];
  "alert-plain-pass.age".publicKeys = [
    keys.other.bootstrap
  ] ++ builtins.attrValues keys.system;
  "storage-box-creds.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "nrab-lol-cf.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "attic-creds.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "github-token.age".publicKeys = [
    keys.system.ude
    keys.system.kazuki
    keys.system.kogata
    keys.other.bootstrap
  ];
  "storage-box-webdav.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "ntfy-niko-pass.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "ntfy-alert-pass.age".publicKeys = (builtins.attrValues keys.system) ++ [ keys.other.bootstrap ];
  "miyagi-niko-pass.age".publicKeys = [
    keys.system.miyagi
    keys.other.bootstrap
  ];
  "rab-lol-cf.age".publicKeys = [
    keys.system.kazuki
    keys.system.youko
    keys.other.bootstrap
  ];
  "rabulinski-com-cf.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "zitadel-master.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "ude-deluge.age".publicKeys = [
    keys.system.ude
    keys.other.bootstrap
  ];
  "youko-niko-pass.age".publicKeys = [
    keys.system.youko
    keys.other.bootstrap
  ];
  "forgejo-token.age".publicKeys = [
    keys.system.youko
    keys.system.ude
    keys.other.bootstrap
  ];
  "paperless-pass.age".publicKeys = [
    keys.system.youko
    keys.other.bootstrap
  ];
  "kanidm-admin-pass.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "kanidm-idm-admin-pass.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
}
