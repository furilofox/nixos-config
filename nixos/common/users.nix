{
  config,
  pkgs,
  lib,
  ...
}: let
  username = config.var.username;
in {
  users = {
    users.${username} = {
      isNormalUser = true;
      description = "${username}";
      initialHashedPassword = "1234";
      extraGroups = ["networkmanager" "wheel"];
    };
  };
}
