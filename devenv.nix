{
  pkgs,
  inputs,
  ...
}: {
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_24;
  };
}
