{config,...}: {
  services.openssh = {
    enable = true;
    ports = [5432];
    settings = {
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [config.var.username];
    };
  };
}
