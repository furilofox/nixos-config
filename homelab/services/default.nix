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
    ./minecraft
    ./paperless-ngx
  ];
}
