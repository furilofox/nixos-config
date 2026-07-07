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
    ./paperless-ngx
  ];
}
