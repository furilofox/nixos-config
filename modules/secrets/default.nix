# Secrets management module (sops-nix)
{ config, lib, inputs, ... }:
let
  cfg = config.secrets;
in {
  options.secrets = {
    enable = lib.mkEnableOption "sops-nix secrets management";

    keyType = lib.mkOption {
      type = lib.types.enum [ "age" "gpg" "age-yubikey" ];
      default = "age";
      description = "Type of encryption key to use";
    };

    ageKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to age private key file";
    };

    sshKeyPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "SSH key paths for age decryption";
    };

    secretsRepo = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to secrets repository (inputs.my-secrets)";
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = lib.mkIf (cfg.secretsRepo != null) 
        "${cfg.secretsRepo}/${config.hostname}.yaml";
      defaultSopsFormat = "yaml";
      
      age = lib.mkIf (cfg.keyType == "age" || cfg.keyType == "age-yubikey") {
        keyFile = lib.mkIf (cfg.ageKeyFile != null) cfg.ageKeyFile;
        sshKeyPaths = lib.mkIf (cfg.sshKeyPaths != []) cfg.sshKeyPaths;
      };
    };
  };
}
