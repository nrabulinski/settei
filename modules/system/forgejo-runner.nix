# Darwin polyfill for forgejo-runner module
# Definitions copied from https://github.com/NixOS/nixpkgs/blob/2786a2a72088ecf32aea5b3ec52099e6a7cff78f/nixos/modules/services/continuous-integration/forgejo-runner.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib)
    foldlAttrs
    literalExpression
    literalMD
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    mkRemovedOptionModule
    mkRenamedOptionModule
    mkDefault
    nameValuePair
    types
    ;

  cfg = config.services.forgejo-runner;
  user = config.users.users._forgejo-runner;
  settingsFormat = pkgs.formats.yaml { };

  # An option type for cfg.secrets that is like cfg.settings (free-form yaml), but limited
  # to just path and attrsOf path. It uses the same implementation primivites as
  # pkgs.formats.yaml (serializableValueWith).
  # The alternative would be something like types.any, which is too weak, or a hard-coded
  # max-depth by chaining multiple types.oneOf and types.attrsOf together, which is both
  # longer in code and less future-proof.
  secretsTypeBase = types.oneOf [
    types.externalPath
    (types.attrsOf secretsTypeBase)
  ];
  secretsType = secretsTypeBase // {
    description = "nested attribute set of ${types.externalPath.description}";
  };

  labels =
    instance:
    instance.settings.runner.labels
    ++ (lib.flatten (
      lib.mapAttrsToList (_: value: value.labels or [ ]) instance.settings.server.connections
    ));
in
{
  meta.maintainers = pkgs.forgejo-runner.meta.maintainers;

  options.services.forgejo-runner = {
    package = mkPackageOption pkgs "forgejo-runner" { };

    instances = mkOption {
      default = { };
      description = ''
        Forgejo Runner instances.
      '';
      type = types.attrsOf (
        types.submodule (
          {
            options,
            config,
            name,
            ...
          }:

          {
            imports = [
              (inputs.nixpkgs + "/nixos/modules/misc/assertions.nix")

              # compat for users coming from nixos/gitea-actions-runner
              (mkRenamedOptionModule [ "url" ] [ "settings" "server" "connections" "default" "url" ])
              (mkRenamedOptionModule [ "labels" ] [ "settings" "runner" "labels" ])
              (mkRemovedOptionModule [ "name" ] ''
                The option `${options.name}' has been removed, because it has no longer
                any effect, as runners no longer self-report their name to Forgejo.
              '')
              (mkRemovedOptionModule [ "token" ] ''
                The option `${options.token}' has been renamed to
                `${options.settings}.server.connections.default.token'
                but additional attention is required.

                Assuming you are migrating from `services.gitea-actions-runner', you will need to:

                 1. Find the old `.runner' file of your previously registered runner. You will need
                    to extract two values from it. Given the instance name of "${name}", you should
                    be able to find it at `/var/lib/gitea-runner/${name}/.runner'.

                 2. Read the contents of it, for example using `cat /var/lib/gitea-runner/${name}/.runner'.

                 3. Take note of the "uuid" and set the option `${options.settings}.server.connections.default.uuid'
                    to that value. For example "c9e50be9-a7c3-4aee-ba35-624c4ff8c519".

                 4. Take note of the "token" and set the option `${options.settings}.server.connections.default.token'
                    to that value. For example "6634bb58be0db23cc013a2e72dd1828ae0257cf".

                 5. Remove option `${options.token}'.
              '')
              (mkRemovedOptionModule [ "tokenFile" ] ''
                The option `${options.tokenFile}' has been renamed to
                `${options.secrets}.server.connections.default.token_url'
                but additional attention is required.

                Assuming you are migrating from `services.gitea-actions-runner', you will need to:

                 1. Find the old `.runner' file of your previously registered runner. You will need
                    to extract two values from it. Given the instance name of "${name}", you should
                    be able to find it at `/var/lib/gitea-runner/${name}/.runner'.

                 2. Read the contents of it, for example using `cat /var/lib/gitea-runner/${name}/.runner'.

                 3. Take note of the "uuid" and set the option `${options.settings}.server.connections.default.uuid'
                    to that value. For example "c9e50be9-a7c3-4aee-ba35-624c4ff8c519".

                 4. Take note of the "token" and replace the contents of your existing token file with it.
                    You no longer need to prefix the token with `TOKEN='. Put just the token in that file
                    and nothing else.

                 5. Rename `${options.tokenFile}' to `${options.secrets}.server.connections.default.token_url'.
              '')
            ];

            config = mkIf config.enable {
              assertions = [
                {
                  assertion = lib.all (label: !(lib.hasInfix ":docker" label)) (labels config);
                  message = "Label configuration on `${options.settings}' requires either docker or podman, which are unavailable on macOS.";
                }
                {
                  assertion = config.settings.server.connections != { };
                  message = ''
                    The option `${options.settings}.server.connections' requires at least one connection.
                  '';
                }
              ]
              ++ (foldlAttrs (
                assertions: _: connection:
                assertions ++ connection.assertions
              ) [ ] config.settings.server.connections);
            };

            options = {
              enable = mkEnableOption "this Forgejo Runner instance";

              settings = mkOption {
                default = { };
                description = ''
                  Free-form settings written directly to the {file}`config.yaml` file.
                  Refer to [`config.example.yaml`] or run {command}`forgejo-runner generation-config` for supported values.

                  [`config.example.yaml`]: https://code.forgejo.org/forgejo/runner/src/branch/main/internal/pkg/config/config.example.yaml
                '';
                type = types.submodule {
                  freeformType = settingsFormat.type;

                  config = lib.mapAttrsRecursive (_path: file: "file:${file}") config.secrets;

                  options = {
                    runner = {
                      labels = mkOption {
                        # TODO: Support new attrset format (yaml map)
                        # https://code.forgejo.org/forgejo/runner/pulls/1571
                        type = types.listOf types.str;
                        example = literalExpression ''
                          [
                            # provide a debian base with nodejs for actions
                            "debian-latest:docker://node:current"
                            # fake the ubuntu name, because node provides no ubuntu builds
                            "ubuntu-latest:docker://node:current"
                            # provide native execution on the host
                            #"native:host"
                          ]
                        '';
                        description = ''
                          Labels used to map jobs to their runtime environment.

                          Many common actions require {command}`bash`, {command}`git` and {command}`node`,
                          as well as a filesystem that follows the filesystem hierarchy standard.

                          If you specify a label of type `docker`, the resulting runner service
                          will be automatically added to the *Podman* or *Docker* group.

                          See <https://forgejo.org/docs/latest/admin/actions/configuration/#choosing-labels>.

                          ::: {.note}
                          Labels of type [`lxc`] are currently not supported.
                          :::

                          [`lxc`]: https://forgejo.org/docs/latest/admin/actions/configuration/#lxc
                        '';
                      };
                    };

                    server = {
                      connections = mkOption {
                        default = { };
                        description = ''
                          One or more connections to Forgejo instances, each with a UUID and Token pair.

                          See <https://forgejo.org/docs/latest/admin/actions/registration/>.

                          ::: {.note}
                          Ephemeral runner mode is not yet supported by this module.
                          :::
                        '';
                        example = literalExpression ''
                          {
                            default = {
                              url = "https://example.com/";
                              uuid = "c9e50be9-a7c3-4aee-ba35-624c4ff8c519";

                              # Also see ${options.secrets}.server.connections.<name>.token_url
                              token = "6634bb58be0db23cc013a2e72dd1828ae0257cf";
                            };
                          }
                        '';
                        type = types.attrsOf (
                          types.submodule (
                            { name, config, ... }:

                            {
                              freeformType = settingsFormat.type;

                              imports = [
                                (inputs.nixpkgs + "/nixos/modules/misc/assertions.nix")
                              ];

                              config = {
                                assertions = [
                                  {
                                    assertion =
                                      (config.token == null && config ? token_url && config.token_url != null)
                                      || (config.token != null && config ? token_url && config.token_url == null)
                                      || (config.token != null && !config ? token_url);
                                    message = ''
                                      The option `${options.settings}' needs to have exactly one of
                                      `server.connections.${name}.token_url': ${
                                        if config ? token_url then lib.toJSON config.token_url else "<not set>"
                                      } or
                                      `server.connections.${name}.token': ${lib.toJSON config.token}
                                      that is *not* null.

                                      Hint:
                                      `${options.secrets}.server.connections.${name}.token_url' will set
                                      `${options.settings}.server.connections.${name}.token_url' for you.
                                    '';
                                  }
                                ];
                              };

                              options = {
                                url = mkOption {
                                  type = types.str;
                                  example = "https://example.com/";
                                  description = ''
                                    Base URL of your Forgejo instance.
                                  '';
                                };
                                uuid = mkOption {
                                  type = types.str;
                                  example = "c9e50be9-a7c3-4aee-ba35-624c4ff8c519";
                                  description = ''
                                    UUID of this runner.

                                    See <https://forgejo.org/docs/latest/admin/actions/registration/>.
                                  '';
                                };
                                token = mkOption {
                                  type = types.nullOr types.str;
                                  example = "6634bb58be0db23cc013a2e72dd1828ae0257cf";
                                  description = ''
                                    Token of this runner.

                                    See <https://forgejo.org/docs/latest/admin/actions/registration/>.

                                    ::: {.note}
                                    The deprecated "Registration Token" is not supported.
                                    You need a UUID and Token pair.
                                    :::

                                    ::: {.warning}
                                    The value will be stored unencrypted in the world-readable Nix store.
                                    To store the secret securely, see {option}`${options.secrets}.server.connections.<name>.token_url`.
                                    :::
                                  '';
                                };
                              };
                            }
                          )
                        );
                      };
                    };
                  };
                };
              };

              secrets = mkOption {
                type = secretsType;
                default = { };
                description = ''
                  This follows the same structure as {option}`${options.settings}`
                  but the value of each key is a path.

                  The specified secret path is then read by systemd via [`LoadCredential=`]
                  and templated into {option}`${options.settings}` for you.

                  [`LoadCredential=`]: https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Credentials
                '';
                example = literalExpression ''
                  {
                    server.connections.example = {
                      token_url = "/run/keys/forgejo-runner_token";
                    };

                    cache = {
                      secret_url = "/run/keys/forgejo-runner_cache-secret";
                    };
                  }
                '';
              };

              hostPackages = mkOption {
                type = types.listOf types.package;
                default = with pkgs; [
                  bash
                  coreutils
                  curl
                  gawk
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
                    gnused
                    nodejs
                    wget
                  ]
                '';
                description = ''
                  List of packages that are available to your workflow and actions when the
                  runner is configured with a label of type `host` ({option}`${options.runtimes.host}`).

                  ::: {.note}
                  {command}`gitMinimal` is always part of the environment because {command}`forgejo-runner`
                  depends on it. If you need a different variant of {command}`git`, e.g. {command}`gitFull`,
                  add it here. Your package will take priority over {command}`gitMinimal`.
                  :::
                '';
              };

              runtimes = {
                host = mkOption {
                  type = types.bool;
                  default = lib.any (label: lib.hasSuffix ":host" label) (labels config);
                  defaultText = literalMD "Whether this instance has at least one label with suffix `:host`.";
                  description = ''
                    Whether to configure the systemd service for jobs with the backend of type `host`.

                    ::: {.warning}
                    Setting this will override the automatic detection and safeguards.
                    :::
                  '';
                };
              };

              configFile = mkOption {
                internal = true;
                readOnly = true;
                type = types.path;
                default = settingsFormat.generate "config.yaml" (
                  # Filter out remains of ../misc/assertions.nix.
                  # Note: This is for optics only, as forgejo-runner simply ignores settings it does not know.
                  lib.filterAttrsRecursive (n: _: n != "assertions" && n != "warnings") config.settings
                );
                description = ''
                  Implementation detail for use in {file}`nixos/tests/forgejo.nix`.

                  FIXME: Offload into top-level config once upstream supports {var}`uuid_url`.
                '';
              };
            };
          }
        )
      );
    };
  };

  config = mkIf (cfg.instances != { }) {
    assertions = foldlAttrs (
      assertions: _: instance:
      assertions ++ instance.assertions
    ) [ ] cfg.instances;

    warnings = foldlAttrs (
      warnings: _: instance:
      warnings ++ instance.warnings
    ) [ ] cfg.instances;

    users.users._forgejo-runner = {
      uid = mkDefault 540;
      gid = mkDefault config.users.groups._forgejo-runner.gid;
      home = "/var/lib/forgejo-runner";
      createHome = true;
      shell = "/bin/bash";
    };
    users.groups._forgejo-runner = {
      gid = mkDefault 540;
    };
    users.knownUsers = [ "_forgejo-runner" ];
    users.knownGroups = [ "_forgejo-runner" ];

    system.activationScripts.preActivation.text =
      lib.strings.concatMapAttrsStringSep "\n" (name: _instance: ''
        mkdir -p "/var/lib/forgejo-runner/${name}"
        touch "/var/lib/forgejo-runner/${name}/act_runner.log"
      '') cfg.instances
      + ''
        chown -R ${toString user.uid}:${toString user.gid} /var/lib/forgejo-runner
      '';

    launchd.daemons =
      let
        mkRunnerService =
          name: instance:
          let
            workDir = "/var/lib/forgejo-runner/${name}";
            systemPath = lib.makeSearchPath "" [
              "/usr/local/bin"
              "/usr/bin"
              "/bin"
              "/usr/sbin"
              "/sbin"
            ];
            hostPath = lib.makeBinPath (instance.hostPackages ++ [ pkgs.gitMinimal ]);
            path = "${hostPath}:${systemPath}";
          in
          # TODO: Sanitize name
          # TODO: Handle lack of token file and inline token
          nameValuePair "forgejo-runner-${name}" {
            serviceConfig = {
              UserName = "_forgejo-runner";
              WorkingDirectory = workDir;
              StandardOutPath = "${workDir}/act_runner.log";
              StandardErrorPath = "${workDir}/act_runner.log";
              RunAtLoad = true;
              KeepAlive = true;
            };
            environment = {
              STATE_DIRECTORY = "/var/lib/forgejo-runner";
              HOME = workDir;
              PATH = path;
            };
            script = ''
              export INSTANCE_DIR="$STATE_DIRECTORY/${name}"
              mkdir -vp "$INSTANCE_DIR"
              cd "$INSTANCE_DIR"

              exec ${lib.getExe cfg.package} daemon --config ${instance.configFile}
            '';
          };
      in
      lib.mapAttrs' mkRunnerService cfg.instances;
  };
}
