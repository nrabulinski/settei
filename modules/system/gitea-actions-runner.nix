# Darwin polyfill for gitea-actions-runner module
# Definitions copied from https://github.com/NixOS/nixpkgs/blob/bba76373684f45f4d3426344ec835f762e34af2e/nixos/modules/services/continuous-integration/gitea-actions-runner.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    any
    attrValues
    concatStringsSep
    escapeShellArg
    hasInfix
    literalExpression
    mapAttrs'
    mkEnableOption
    mkOption
    mkPackageOption
    mkIf
    nameValuePair
    types
    ;

  cfg = config.services.gitea-actions-runner;

  settingsFormat = pkgs.formats.yaml { };

  # Check whether any runner instance label requires a container runtime
  # Empty label strings result in the upstream defined defaultLabels, which require docker
  # https://gitea.com/gitea/act_runner/src/tag/v0.1.5/internal/app/cmd/register.go#L93-L98
  hasDockerScheme =
    instance: instance.labels == [ ] || any (label: hasInfix ":docker:" label) instance.labels;
  wantsContainerRuntime = any hasDockerScheme (attrValues cfg.instances);

  tokenXorTokenFile =
    instance:
    (instance.token == null && instance.tokenFile != null)
    || (instance.token != null && instance.tokenFile == null);
in
{
  meta.maintainers = with lib.maintainers; [
    hexa
  ];

  options.services.gitea-actions-runner = with types; {
    package = mkPackageOption pkgs "gitea-actions-runner" { };

    instances = mkOption {
      default = { };
      description = ''
        Gitea Actions Runner instances.
      '';
      type = attrsOf (submodule {
        options = {
          enable = mkEnableOption "Gitea Actions Runner instance";

          name = mkOption {
            type = str;
            example = literalExpression "config.networking.hostName";
            description = ''
              The name identifying the runner instance towards the Gitea/Forgejo instance.
            '';
          };

          url = mkOption {
            type = str;
            example = "https://forge.example.com";
            description = ''
              Base URL of your Gitea/Forgejo instance.
            '';
          };

          token = mkOption {
            type = nullOr str;
            default = null;
            description = ''
              Plain token to register at the configured Gitea/Forgejo instance.
            '';
          };

          tokenFile = mkOption {
            type = nullOr (either str path);
            default = null;
            description = ''
              Path to an environment file, containing the `TOKEN` environment
              variable, that holds a token to register at the configured
              Gitea/Forgejo instance.
            '';
          };

          labels = mkOption {
            type = listOf str;
            example = literalExpression ''
              [
                # provide native execution on the host
                "native:host"
              ]
            '';
            description = ''
              Labels used to map jobs to their runtime environment. Changing these
              labels currently requires a new registration token.

              Many common actions require bash, git and nodejs, as well as a filesystem
              that follows the filesystem hierarchy standard.
            '';
          };
          settings = mkOption {
            description = ''
              Configuration for `act_runner daemon`.
              See <https://gitea.com/gitea/act_runner/src/branch/main/internal/pkg/config/config.example.yaml> for an example configuration
            '';

            type = types.submodule {
              freeformType = settingsFormat.type;
            };

            default = { };
          };

          hostPackages = mkOption {
            type = listOf package;
            default = with pkgs; [
              bash
              coreutils
              curl
              gawk
              gitMinimal
              gnused
              nodejs
              wget
            ];
            defaultText = literalExpression ''
              with pkgs; [
                bash
                coreutils
                curl
                gawk
                gitMinimal
                gnused
                nodejs
                wget
              ]
            '';
            description = ''
              List of packages, that are available to actions, when the runner is configured
              with a host execution label.
            '';
          };
        };
      });
    };
  };

  config = mkIf (cfg.instances != { }) {
    assertions = [
      {
        assertion = any tokenXorTokenFile (attrValues cfg.instances);
        message = "Instances of gitea-actions-runner can have `token` or `tokenFile`, not both.";
      }
      {
        assertion = !wantsContainerRuntime;
        message = "Label configuration on gitea-actions-runner instance requires either docker or podman, which are unavailable on macOS.";
      }
    ];

    users.users._gitea-runner = {
      uid = lib.mkDefault 394;
      gid = lib.mkDefault config.users.groups._gitea-runner.gid;
      home = "/var/lib/gitea-runner";
      createHome = true;
      shell = "/bin/bash";
    };
    users.groups._gitea-runner = {
      gid = lib.mkDefault 394;
    };
    users.knownUsers = [ "_gitea-runner" ];
    users.knownGroups = [ "_gitea-runner" ];

    system.activationScripts.preActivation.text =
      lib.strings.concatMapAttrsStringSep "\n"
        # TODO: Support changing the uid and gid
        (name: _instance: ''
          mkdir -p "/var/lib/gitea-runner/${name}"
          touch "/var/lib/gitea-runner/${name}/act_runner.log"
        '')
        cfg.instances
      + ''
        chown -R ${toString 394}:${toString 394} /var/lib/gitea-runner
      '';

    launchd.daemons =
      let
        mkRunnerService =
          name: instance:
          let
            configFile = settingsFormat.generate "config.yaml" instance.settings;
            systemPath = lib.makeSearchPath "" [
              "/usr/local/bin"
              "/usr/bin"
              "/bin"
              "/usr/sbin"
              "/sbin"
            ];
            hostPath = lib.makeBinPath ([ pkgs.coreutils ] ++ instance.hostPackages);
            path = "${systemPath}:${hostPath}";
            workDir = "/var/lib/gitea-runner/${name}";
          in
          # TODO: Sanitize name
          # TODO: Handle lack of token file and inline token
          nameValuePair "gitea-runner-${name}" {
            serviceConfig = {
              UserName = "_gitea-runner";
              WorkingDirectory = workDir;
              StandardOutPath = "${workDir}/act_runner.log";
              StandardErrorPath = "${workDir}/act_runner.log";
              RunAtLoad = true;
              KeepAlive = true;
            };
            environment = {
              STATE_DIRECTORY = "/var/lib/gitea-runner";
              HOME = workDir;
              PATH = path;
            };
            script = ''
              source "${instance.tokenFile}"
              export INSTANCE_DIR="$STATE_DIRECTORY/${name}"
              mkdir -vp "$INSTANCE_DIR"
              cd "$INSTANCE_DIR"

              # force reregistration on changed labels
              export LABELS_FILE="$INSTANCE_DIR/.labels"
              export LABELS_WANTED="$(echo ${escapeShellArg (concatStringsSep "\n" instance.labels)} | sort)"
              export LABELS_CURRENT="$(cat $LABELS_FILE 2>/dev/null || echo 0)"

              if [ ! -e "$INSTANCE_DIR/.runner" ] || [ "$LABELS_WANTED" != "$LABELS_CURRENT" ]; then
                # remove existing registration file, so that changing the labels forces a re-registration
                rm -v "$INSTANCE_DIR/.runner" || true

                # perform the registration
                ${cfg.package}/bin/act_runner register --no-interactive \
                  --instance ${escapeShellArg instance.url} \
                  --token "$TOKEN" \
                  --name ${escapeShellArg instance.name} \
                  --labels ${escapeShellArg (concatStringsSep "," instance.labels)} \
                  --config ${configFile}

                # and write back the configured labels
                echo "$LABELS_WANTED" > "$LABELS_FILE"
              fi

              exec ${cfg.package}/bin/act_runner daemon --config ${configFile}
            '';
          };
      in
      mapAttrs' mkRunnerService cfg.instances;
  };
}
