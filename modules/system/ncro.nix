# Darwin polyfill for ncro module
# Definitions copied from https://github.com/manic-systems/ncro/blob/3cc83303cc859901eb4330e9c4319b61f6ba1ffc/nix/module.nix
{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault mkAfter;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types)
    bool
    package
    nullOr
    path
    ;
  inherit (lib.lists) optional;

  tomlFormat = pkgs.formats.toml { };
  tomlType = tomlFormat.type;

  cfg = config.services.ncro;
  configFile = tomlFormat.generate "ncro.toml" cfg.settings;

  publicKeysFor =
    upstream:
    optional ((upstream.public_key or "") != "") upstream.public_key ++ (upstream.public_keys or [ ]);

  upstreamPublicKeysFor =
    settings:
    let
      fallbackPublicKeys =
        if settings.fallback_cache.enabled or false then
          publicKeysFor (
            settings.fallback_cache
            // {
              public_key =
                settings.fallback_cache.public_key
                  or "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
            }
          )
        else
          [ ];
    in
    lib.pipe ((settings.upstreams or [ ]) ++ [ fallbackPublicKeys ]) [
      (builtins.map (upstream: if builtins.isAttrs upstream then publicKeysFor upstream else upstream))
      lib.flatten
      (builtins.filter (key: key != ""))
      lib.unique
    ];

  upstreamPublicKeys = upstreamPublicKeysFor cfg.settings;
in
{
  options.services.ncro = {
    enable = mkEnableOption "ncro, the Nix cache route optimizer";

    addUpstreamPublicKeys = mkOption {
      type = bool;
      default = true;
      description = ''
        Append non-empty upstream public_key and public_keys values from {option}`services.ncro.settings`
        to {option}`nix.settings.trusted-public-keys`.

        This keeps Nix client signature validation aligned with the upstream
        caches that ncro is allowed to route to. Disable this if you manage Nix
        trusted public keys separately.
      '';
    };

    package = mkOption {
      type = package;
      default = pkgs.callPackage "${inputs.ncro}/nix/package.nix" { };
      defaultText = literalExpression "inputs.ncro.packages.$${system}.ncro";
      description = "The ncro package to use.";
      example = literalExpression "inputs.ncro.packages.$${system}.ncro";
    };

    netrcFile = mkOption {
      type = nullOr path;
      default = null;
      example = "/etc/nix/netrc";
      description = ''
        The path to netrc file for upstream authentication.
        If null, ncro will not use netrc for upstream authentication.
      '';
    };

    settings = mkOption {
      type = tomlType;
      default = { };
      description = ''
        ncro configuration as an attribute set.

        Keys and structure match the TOML config file format; all defaults are
        handled by the ncro binary.
      '';
      example = {
        logging.level = "info";
        server = {
          listen = ":8080";
          cache_priority = 20;
        };

        upstreams = [
          {
            url = "https://cache.nixos.org";
            priority = 10;
          }
          {
            url = "https://nix-community.cachix.org";
            priority = 20;
          }
        ];

        cache = {
          ttl = "2h";
          negative_ttl = "15m";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    nix.settings.trusted-public-keys = mkIf cfg.addUpstreamPublicKeys (mkAfter upstreamPublicKeys);

    users.users._ncro = {
      uid = mkDefault 529;
      gid = mkDefault config.users.groups._ncro.gid;
      home = "/var/lib/ncro";
      createHome = true;
    };
    users.groups._ncro = {
      gid = mkDefault 529;
    };
    users.knownUsers = [ "_ncro" ];
    users.knownGroups = [ "_ncro" ];

    launchd.daemons.ncro =
      let
        home = config.users.users._ncro.home;
      in
      {
        serviceConfig = {
          UserName = "_ncro";
          GroupName = "_ncro";
          WorkingDirectory = home;
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "${home}/ncro.log";
          StandardErrorPath = "${home}/ncro.log";
        };
        environment = mkIf (cfg.netrcFile != null) {
          NETRC = cfg.netrcFile;
        };
        script = ''
          exec ${lib.getExe' cfg.package "ncro"} --config ${configFile}
        '';
      };
  };
}
