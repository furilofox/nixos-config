{...}: {
  # Enable printer support
  services.printing = {
    enable = true;
    drivers = [pkgs.gutenprint pkgs.hplip];
  };
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
}
