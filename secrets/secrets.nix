let
  keys = import ../assets/ssh.nix;
in {
  "leet-nrab-lol-pass.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "alert-nrab-lol-pass.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  "vault-cert-env.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
  # "bitwarden-env-file.age".publicKeys = [keys.system.kazuki keys.other.bootstrap];
  "hercules-token.age".publicKeys = [
    keys.system.kazuki
    keys.system.legion
    keys.system.ude
    keys.system.kogata
    keys.other.bootstrap
  ];
  "hercules-cache.age".publicKeys = [
    keys.system.kazuki
    keys.system.legion
    keys.system.ude
    keys.system.kogata
    keys.other.bootstrap
  ];
  "hercules-secrets.age".publicKeys = [
    keys.system.kazuki
    keys.system.legion
    keys.system.ude
    keys.system.kogata
    keys.other.bootstrap
  ];
  "alert-plain-pass.age".publicKeys = [
    keys.system.legion
    keys.other.bootstrap
  ];
  "legion-niko-pass.age".publicKeys = [
    keys.system.legion
    keys.other.bootstrap
  ];
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
    keys.system.legion
    keys.system.kogata
    keys.other.bootstrap
  ];
  "storage-box-webdav.age".publicKeys = [
    keys.system.kazuki
    keys.other.bootstrap
  ];
}
