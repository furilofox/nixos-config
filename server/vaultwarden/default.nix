{ pkgs, ... }: {
    services.vaultwarden = {
        enable = true;
        package = pkgs.vaultwarden;
    };
}