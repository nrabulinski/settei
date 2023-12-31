let
  keys = import ../assets/ssh.nix;
in {
  "leet-nrab-lol-pass.age".publicKeys = [keys.system.kazuki keys.other.bootstrap];
  "alert-nrab-lol-pass.age".publicKeys = [keys.system.kazuki keys.other.bootstrap];
  "vault-cert-env.age".publicKeys = [keys.system.kazuki keys.other.bootstrap];
  # "bitwarden-env-file.age".publicKeys = [keys.system.kazuki keys.other.bootstrap];
  "hercules-token.age".publicKeys = [keys.system.kazuki keys.system.legion keys.system.ude keys.other.bootstrap];
  "hercules-cache.age".publicKeys = [keys.system.kazuki keys.system.legion keys.system.ude keys.other.bootstrap];
  "alert-plain-pass.age".publicKeys = [keys.system.legion keys.other.bootstrap];
  "legion-niko-pass.age".publicKeys = [keys.system.legion keys.other.bootstrap];
}
