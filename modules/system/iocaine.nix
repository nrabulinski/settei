# Inspired by:
# https://git.poz.pet/poz/niksos/src/commit/fed9c77ffca1d202a9e1b6454e2b15fe123e8083/hosts/szparag/services/forgejo.nix
# https://iocaine.madhouse-project.org/documentation/3/getting-started/nixos/
{ isLinux }:
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    ;
  hashString = lib.hashString "sha256";

  inherit (pkgs)
    fetchurl
    ;

  cfg = config.settei.iocaine;

  iocaineHost = "http://127.0.0.1:${toString cfg.port}";

  rawOptions = types.attrsOf types.raw;

  hostType = types.submodule (
    { name, ... }: {
      options = {
        hostName = mkOption {
          type = types.str;
          default = name;
        };
        locations = mkOption {
          type = types.attrsOf rawOptions;
          description = ''
            Locations to be protected by iocaine. The options are the same as `services.nginx.virtualHosts.<name>.locations`.
            If there are any locations which should be excluded, use `extraNginxConfig.locations` instead.
            For the module to function correctly use semantic options, e.g. locations.<name>.proxyPass,
            instead of writing `proxy_pass` inside of `extraConfig`, which will result in broken configuration.
          '';
          default = { };
        };
        extraNginxConfig = mkOption {
          type = rawOptions;
          description = ''
            Extra nginx options to append to the virtualHosts block.
            May be removed in the future if I decide to use another reverse proxy.
          '';
          default = { };
        };
      };
    }
  );

  mkLocationVarName =
    pathStr:
    let
      h = hashString pathStr;
    in
    "\$_iocaine_${h}_location";

  mkFallbackVarName =
    pathStr:
    let
      h = hashString pathStr;
    in
    "@_iocaine_${h}_fallback";

  mkIocaineUpstream =
    serverHash: path: cfg:
    let
      name = mkLocationVarName "${serverHash}${path}";
    in
    lib.optionalString (cfg.proxyPass != null) ''
      map $request_method ${name} {
        GET ${iocaineHost};
        HEAD ${iocaineHost};
        default ${cfg.proxyPass};
      }
    '';

  mkIocaineLocation =
    serverHash: path: cfg:
    let
      locationVarName =
        if cfg.proxyPass == null then iocaineHost else (mkLocationVarName "${serverHash}${path}");
      fallbackVarName = mkFallbackVarName path;
    in
    {
      locations.${path} = {
        recommendedProxySettings = false;
        recommendedUwsgiSettings = false;
        extraConfig = ''
          proxy_cache off;
          proxy_intercept_errors on;
          proxy_set_header Host $host;
          proxy_pass ${locationVarName};

          error_page 421 = ${fallbackVarName};
        '';
      };

      locations.${fallbackVarName} = cfg;
    };

  linuxConfig = lib.optionalAttrs isLinux {
    services.iocaine = {
      enable = true;
      settings.server.default = {
        bind = "127.0.0.1:${toString cfg.port}";
        mode = "http";
        use.handler-from = "default";
      };
      settings.handler.default.config = {
        "ai-robots-txt-path" = "${inputs.ai-robots-txt}/robots.json";

        sources = {
          training-corpus = [
            (fetchurl {
              url = "https://archive.org/download/GeorgeOrwells1984/1984_djvu.txt";
              hash = "sha256-9R1PTa8yDtkfH+4rU5BF62ee73irhd3VYX1QB5KU+ZU=";
            })

            (fetchurl {
              url = "https://archive.org/download/ost-english-brave_new_world_aldous_huxley/Brave_New_World_Aldous_Huxley_djvu.txt";
              hash = "sha256-6WkaO/3zQIezGzJDp4QjglikiTZTxgo0P4MEff2mdcY=";
            })
          ];

          wordlists = [
            (fetchurl {
              url = "https://git.savannah.gnu.org/cgit/miscfiles.git/plain/web2";
              hash = "sha256-KSmJWrP+x4xpY+vly7NJP+T8nhHroJWlInh7ivxTqGM=";
            })
          ];
        };

        unwanted-asns = {
          db-path = "${inputs.geolite2-asn-mmdb}/GeoLite2-ASN.mmdb";
          list = map toString [
            7552 # VIETEL-AS-AP
            37963 # ALIBABA-CN-NET
            45102 # ALIBABA-CN-NET
            45899 # VNPT-AS-VN
            51167 # CONTABO
            62610 # ZEN-DPS
            132203 # TENCENT-NET-AP-CN
            136907 # HWCLOUDS-AS-AP
            21859 # ZEN-ECN
            62874 # WEB2OBJECTS
            203020 # HOSTROYALE
          ];
        };

        unwanted-visitors = [
          "iPod;"
          "Presto/"
          "Trident/"
          "Windows CE"
          "efx-scanner/3.0"
          "Go-http-client/1.1"
        ];
      };
    };

    services.nginx.enable = true;
    services.nginx.appendHttpConfig =
      let
        allLocs = lib.mapAttrsToList (
          _: host:
          let
            mkLoc = mkIocaineUpstream (hashString host.hostName);
          in
          lib.mapAttrsToList mkLoc host.locations
        ) cfg.protectedHosts;
        allLocs' = lib.flatten allLocs;
        # NGINX lowered the default size to 64, which is not enough to hold all of the fallback variables etc.
        varSize = ''
          variables_hash_bucket_size 512;
        '';
      in
      lib.mkMerge (allLocs' ++ [ varSize ]);
    services.nginx.virtualHosts = lib.mapAttrs (
      _: host:
      let
        mkLoc = mkIocaineLocation (hashString host.hostName);
        locationConfigs = lib.mapAttrsToList mkLoc host.locations;
      in
      lib.mkMerge (
        [
          {
            serverName = host.hostName;
            extraConfig = ''
              recursive_error_pages on;
            '';
          }
          host.extraNginxConfig
        ]
        ++ locationConfigs
      )
    ) cfg.protectedHosts;
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    assertions = [
      {
        assertion = !cfg.enable;
        message = "settei.iocaine doesn't support Darwin yet";
      }
    ];
  };
in
{
  _file = ./iocaine.nix;

  options.settei.iocaine = {
    enable = (mkEnableOption "iocaine, the deadliest poison known to AI") // {
      default = cfg.protectedHosts != { };
    };
    port = mkOption {
      type = types.port;
      default = 1849;
    };
    protectedHosts = mkOption {
      type = types.attrsOf hostType;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      linuxConfig
      darwinConfig
    ]
  );
}
