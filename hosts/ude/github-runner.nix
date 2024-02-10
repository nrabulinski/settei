{config, ...}: let
  github-runner-user = "github-runner";
in {
  age.secrets.github-token = {
    file = ../../secrets/github-token.age;
    owner = github-runner-user;
  };

  services.github-runners.settei = {
    enable = true;
    tokenFile = config.age.secrets.github-token.path;
    url = "https://github.com/nrabulinski/settei";
    ephemeral = true;
    user = github-runner-user;
    serviceOverrides = {
      DynamicUser = false;
    };
  };

  users = {
    users.${github-runner-user} = {
      isSystemUser = true;
      group = github-runner-user;
    };
    groups.${github-runner-user} = {};
  };
}
