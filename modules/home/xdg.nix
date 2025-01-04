{ config, ... }:
let
  inherit (config.xdg)
    dataHome
    cacheHome
    configHome
    stateHome
    ;
in
{
  xdg.enable = true;

  home.sessionVariables = {
    SQLITE_HISTORY = "${cacheHome}/sqlite_history";
    PSQL_HISTORY = "${dataHome}/psql_history";
    NPM_CONFIG_USERCONFIG = "${configHome}/npm/npmrc";
    NODE_REPL_HISTORY = "${dataHome}/node_repl_history";
    LESSHISTFILE = "${stateHome}/less/history";
    GRADLE_USER_HOME = "${dataHome}/gradle";
    GEM_SPEC_CACHE = "${cacheHome}/gem";
    GEM_HOME = "${dataHome}/gem";
    CP_HOME_DIR = "${dataHome}/cocoapods";
    CARGO_HOME = "${dataHome}/cargo";
    W3M_DIR = "${dataHome}/w3m";
    STACK_XDG = 1;
  };

  # TODO: Manage npmrc with nix too
}
