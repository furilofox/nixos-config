# Enable Touchpad support.
{...}: {
  services.libinput.enable = true;

  # Set Right Click to be Mousepad Bottom right instead of 2 Finger Click
  dconf.settings = {
    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "areas";
    };
  };
}
