# Users module
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    users.users.${config.username} = {
      isNormalUser = true;
      description = config.username;
      initialPassword = "1234";
      extraGroups = ["networkmanager" "wheel"];
    };
  };
}
