{
  config,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./adguard
    ./caddy
    ./homepage
    ./open-webui
    ./paperless-ngx
  ];
}
