# Modular NixOS Configuration Refactoring Plan

## Overview

This plan restructures your NixOS configuration to be **fully modular with declarative options**, enabling easy feature toggles, per-host overrides, consistent sops-nix secrets management, and Niri + noctalia shell support.

## User Review Required

> [!NOTE]
> **Decisions Made:**
> - Options namespace: `config.*` (e.g., `config.desktop.niri.enable`)
> - Secrets: Separate private repository
> - pandora/promethea share a "desktop" profile for common packages

---

## Current State Analysis

### Existing Architecture
```
nixos-config/
├── flake.nix                    # 3 hosts: pandora, promethea, athenas
├── hosts/
│   ├── pandora/                 # Desktop with Hyprland, sops-nix + YubiKey
│   ├── promethea/               # Desktop (no sops)
│   └── athenas/                 # Server/homelab (plaintext secrets.nix)
├── nixos/
│   ├── common/                  # Base modules (audio, boot, networking...)
│   ├── desktop/                 # Desktop environments (hyprland, gnome, niri)
│   ├── hardware/                # Hardware configs (amd)
│   └── services/                # System services
├── home/
│   ├── programs/                # Home-manager programs
│   ├── scripts/                 # User scripts
│   └── system/                  # Home-manager system settings
└── homelab/
    ├── services/                # Homelab services with good options pattern
    └── gameserver/              # Game servers
```

### Strengths to Keep
- [homelab/default.nix](file:///home/fabian/Documents/nixos-config/homelab/default.nix): Excellent parent options pattern (`lib.mkEnableOption`, `lib.mkOption`)
- [homelab/services/caddy/default.nix](file:///home/fabian/Documents/nixos-config/homelab/services/caddy/default.nix): Great submodule options with typed routes
- [nixos/common/audio.nix](file:///home/fabian/Documents/nixos-config/nixos/common/audio.nix): Clean `system.audio.enable` toggle pattern

### Issues to Address
1. **Inconsistent options**: Some modules use `config.var`, others use `system.*`, homelab uses `homelab.*`
2. **No unified enable pattern**: Must manually import modules instead of toggling options
3. **sops-nix inconsistency**: Only pandora uses it; athenas uses plaintext `secrets.nix`
4. **Empty niri directory**: Wayland compositor not implemented
5. **Variables duplication**: Each host duplicates option definitions

---

## Proposed Architecture

### New Directory Structure
```
nixos-config/
├── flake.nix                    # Enhanced with sops-nix for all hosts
├── lib/                         # [NEW] Shared library functions
│   └── default.nix              # Common helpers (mkHost, mkModule, etc.)
├── profiles/                    # [NEW] Shared config profiles
│   ├── desktop.nix              # Shared desktop config (pandora + promethea)
│   └── server.nix               # Server config (athenas)
├── modules/                     # [NEW] Unified module system
│   ├── default.nix              # Imports all modules, defines top-level options
│   ├── core/                    # Core modules
│   │   ├── default.nix          
│   │   ├── audio.nix            # config.audio.* options
│   │   ├── boot.nix             # config.boot.* options
│   │   ├── networking.nix       # config.network.* options
│   │   ├── locale.nix           # config.locale.* options
│   │   └── security.nix         # config.security.* options
│   ├── desktop/                 # Desktop environment modules
│   │   ├── default.nix
│   │   ├── niri/                # config.desktop.niri.* options
│   │   │   ├── default.nix
│   │   │   └── config.kdl        
│   │   └── hyprland/            # config.desktop.hyprland.* options
│   ├── programs/                # Application modules
│   │   ├── default.nix
│   │   ├── gaming.nix           # config.programs.gaming.* options
│   │   ├── development.nix      # config.programs.development.* options
│   │   └── browsers.nix         # config.programs.browsers.* options
│   ├── services/                # System services modules
│   │   └── ...
│   ├── hardware/                # Hardware-specific modules
│   │   └── ...
│   └── secrets/                 # [NEW] Secrets management module
│       └── default.nix          # config.secrets.* options
├── homelab/                     # Keep existing, integrate with new pattern
├── home-modules/                # [NEW] Home-manager modules with options
│   ├── default.nix
│   └── ...
├── hosts/
│   ├── pandora/
│   │   ├── default.nix          # [RENAME] Main config, imports profiles/desktop.nix
│   │   ├── hardware.nix         # Hardware-configuration
│   │   └── overrides.nix        # [NEW] Host-specific overrides
│   ├── promethea/               # Laptop - also imports profiles/desktop.nix
│   └── athenas/                 # Server - imports profiles/server.nix
└── [SEPARATE PRIVATE REPO: nixos-secrets]
    ├── .sops.yaml               # Sops configuration
    ├── common.yaml              # Shared secrets across hosts
    ├── pandora.yaml             # Host-specific secrets
    ├── athenas.yaml
    └── promethea.yaml
```

---

## Proposed Changes

### Phase 1: Foundation - Library & Module System

#### [NEW] [lib/default.nix](file:///home/fabian/Documents/nixos-config/lib/default.nix)
```nix
{ lib, inputs, ... }:
{
  # Helper to create a host configuration
  mkHost = { hostname, system ? "x86_64-linux", modules ? [] }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs hostname; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
        ../modules
        ../hosts/${hostname}
      ] ++ modules;
    };

  # Helper for creating toggleable modules
  mkModule = { name, cfg, ... }@args:
    { config, lib, ... }: {
      options.${name} = args.options or {};
      config = lib.mkIf (cfg.enable or false) (args.config or {});
    };
}
```

---

#### [NEW] [modules/default.nix](file:///home/fabian/Documents/nixos-config/modules/default.nix)
Top-level module options definition with global variables:
```nix
{ config, lib, ... }: {
  imports = [
    ./core
    ./desktop
    ./programs
    ./services
    ./hardware
    ./secrets
  ];

  options.system = {
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "System hostname";
    };
    username = lib.mkOption {
      type = lib.types.str;
      default = "fabian";
      description = "Primary user";
    };
    configDirectory = lib.mkOption {
      type = lib.types.path;
      default = /home/${config.system.username}/Documents/nixos-config;
    };
    # ... other global options migrated from variables.nix
  };
}
```

---

### Phase 1.5: Profiles for Shared Configuration

#### [NEW] [profiles/desktop.nix](file:///home/fabian/Documents/nixos-config/profiles/desktop.nix)
Shared configuration for desktop machines (pandora + promethea):
```nix
# Shared desktop profile for pandora (desktop) and promethea (laptop)
{ config, lib, pkgs, ... }: {
  # Enable all desktop features
  config = {
    # Audio with low-latency for desktop use
    audio = {
      enable = true;
      lowLatency = true;
      jack = true;
    };

    # Bluetooth for peripherals
    bluetooth.enable = true;

    # Desktop environment - Niri with noctalia
    desktop.niri = {
      enable = true;
      shell = "noctalia";
      layout.gaps = 8;
    };

    # Common desktop programs
    programs = {
      gaming.enable = true;
      development.enable = true;
      browsers = {
        zen.enable = true;
        brave.enable = true;
      };
    };

    # Services
    services = {
      mullvad.enable = true;
      onepassword.enable = true;
    };

    # Secrets
    secrets.enable = true;
  };

  # Common packages for both machines
  environment.systemPackages = with pkgs; [
    # Clipboard & screenshots
    wl-clipboard
    cliphist
    grim
    slurp
    hyprpicker
    
    # Media
    kitty
    
    # Utilities
    unixtools.netstat
    dig
  ];
}
```

#### [NEW] [profiles/server.nix](file:///home/fabian/Documents/nixos-config/profiles/server.nix)
```nix
# Server profile for athenas
{ config, lib, ... }: {
  config = {
    # No audio on server
    audio.enable = false;
    bluetooth.enable = false;
    
    # No desktop
    desktop.niri.enable = false;
    
    # Server secrets
    secrets.enable = true;
  };
}
```

---

### Phase 2: Core Modules Refactoring

#### [MODIFY] [modules/core/audio.nix](file:///home/fabian/Documents/nixos-config/modules/core/audio.nix)
Migrate from [nixos/common/audio.nix](file:///home/fabian/Documents/nixos-config/nixos/common/audio.nix) with enhanced options:
```nix
{ config, lib, ... }:
let cfg = config.system.audio;
in {
  options.system.audio = {
    enable = lib.mkEnableOption "PipeWire audio system";
    lowLatency = lib.mkEnableOption "Low-latency audio configuration";
    jack = lib.mkEnableOption "JACK audio support";
    # ... more options
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = cfg.jack;
      # ... conditionally apply lowLatency config
    };
  };
}
```

---

### Phase 3: Desktop Environment Modules

#### [NEW] [modules/desktop/niri/default.nix](file:///home/fabian/Documents/nixos-config/modules/desktop/niri/default.nix)
Niri compositor module with full configuration options:
```nix
{ config, lib, pkgs, inputs, ... }:
let cfg = config.system.desktop.niri;
in {
  options.system.desktop.niri = {
    enable = lib.mkEnableOption "Niri scrollable-tiling Wayland compositor";
    
    shell = lib.mkOption {
      type = lib.types.enum [ "noctalia" "waybar" "none" ];
      default = "noctalia";
      description = "Desktop shell to use with Niri";
    };

    layout = {
      gaps = lib.mkOption {
        type = lib.types.int;
        default = 8;
        description = "Gap between windows in pixels";
      };
      border.width = lib.mkOption {
        type = lib.types.int;
        default = 2;
      };
      # ... more layout options
    };

    keybindings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional keybindings";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          width = lib.mkOption { type = lib.types.int; };
          height = lib.mkOption { type = lib.types.int; };
          refresh = lib.mkOption { type = lib.types.int; default = 60; };
          position = lib.mkOption { type = lib.types.str; default = "0,0"; };
          scale = lib.mkOption { type = lib.types.float; default = 1.0; };
        };
      });
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;  # nixpkgs has niri module
    
    # Required services for Wayland
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };

    # XDG portal for screen sharing
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
    ];

    # Enable noctalia shell if selected
    system.desktop.noctalia.enable = lib.mkIf (cfg.shell == "noctalia") true;
  };
}
```

---

#### [NEW] [modules/desktop/noctalia/default.nix](file:///home/fabian/Documents/nixos-config/modules/desktop/noctalia/default.nix)
```nix
{ config, lib, pkgs, inputs, ... }:
let cfg = config.system.desktop.noctalia;
in {
  options.system.desktop.noctalia = {
    enable = lib.mkEnableOption "Noctalia desktop shell";
    
    colorScheme = lib.mkOption {
      type = lib.types.str;
      default = "lavender";
      description = "Color scheme for noctalia";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.system}.default
      inputs.quickshell.packages.${pkgs.system}.default
    ];
  };
}
```

---

### Phase 4: Secrets Management with sops-nix

#### [NEW] [modules/secrets/default.nix](file:///home/fabian/Documents/nixos-config/modules/secrets/default.nix)
```nix
{ config, lib, inputs, ... }:
let 
  cfg = config.system.secrets;
  hostname = config.system.hostname;
in {
  options.system.secrets = {
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
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "SSH key paths for age decryption";
    };

    secretsPath = lib.mkOption {
      type = lib.types.path;
      default = ../secrets;
      description = "Path to secrets directory";
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = cfg.secretsPath + "/${hostname}.yaml";
      defaultSopsFormat = "yaml";
      
      age = lib.mkIf (cfg.keyType == "age" || cfg.keyType == "age-yubikey") {
        keyFile = lib.mkIf (cfg.ageKeyFile != null) cfg.ageKeyFile;
        sshKeyPaths = lib.mkIf (cfg.sshKeyPaths != []) cfg.sshKeyPaths;
      };
    };
  };
}
```

#### [NEW] [secrets/.sops.yaml](file:///home/fabian/Documents/nixos-config/secrets/.sops.yaml)
```yaml
keys:
  # User keys
  - &fabian_yubikey_primary AGE-PLUGIN-YUBIKEY-1C537CQVZFHGZCHS5QHCXQ
  - &fabian_yubikey_backup AGE-PLUGIN-YUBIKEY-1SRXDZQVZGULA6DQNFDM77
  
  # Host keys (generate with: ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub)
  - &pandora_host age1...  # Pandora's host key
  - &athenas_host age1...  # Athenas' host key
  - &promethea_host age1... # Promethea's host key

creation_rules:
  - path_regex: secrets/common\.yaml$
    key_groups:
      - age:
          - *fabian_yubikey_primary
          - *fabian_yubikey_backup
          - *pandora_host
          - *athenas_host
          - *promethea_host

  - path_regex: secrets/pandora\.yaml$
    key_groups:
      - age:
          - *fabian_yubikey_primary
          - *fabian_yubikey_backup
          - *pandora_host

  - path_regex: secrets/athenas\.yaml$
    key_groups:
      - age:
          - *fabian_yubikey_primary
          - *fabian_yubikey_backup
          - *athenas_host

  - path_regex: secrets/promethea\.yaml$
    key_groups:
      - age:
          - *fabian_yubikey_primary
          - *fabian_yubikey_backup
          - *promethea_host
```

---

## Private Secrets Repository Setup Guide

This guide walks you through setting up a **private Git repository** for your encrypted secrets.

### Step 1: Create the Private Repository

```bash
# Create a new private repo on GitHub (or your preferred host)
# Go to: https://github.com/new
# - Name: nixos-secrets (or similar)
# - Visibility: Private
# - Do NOT initialize with README

# Clone it locally
mkdir -p ~/Documents/nixos-secrets
cd ~/Documents/nixos-secrets
git init
```

### Step 2: Generate Host Age Keys

Each host needs an age key derived from its SSH host key:

```bash
# On each host, get the age public key from SSH host key
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub

# Example outputs (save these!):
# pandora:   age1abc123...
# promethea: age1def456...
# athenas:   age1ghi789...
```

### Step 3: Create .sops.yaml Configuration

```bash
cd ~/Documents/nixos-secrets
cat > .sops.yaml << 'EOF'
keys:
  # Your YubiKey keys (for editing secrets)
  - &fabian_yubikey_primary AGE-PLUGIN-YUBIKEY-1C537CQVZFHGZCHS5QHCXQ
  - &fabian_yubikey_backup AGE-PLUGIN-YUBIKEY-1SRXDZQVZGULA6DQNFDM77
  
  # Host keys (replace with actual keys from step 2)
  - &pandora_host age1abc123...   # Replace with actual
  - &promethea_host age1def456... # Replace with actual  
  - &athenas_host age1ghi789...   # Replace with actual

creation_rules:
  # Common secrets - all hosts can decrypt
  - path_regex: common\.yaml$
    key_groups:
      - age:
          - *fabian_yubikey_primary
          - *fabian_yubikey_backup
          - *pandora_host
          - *promethea_host
          - *athenas_host

  # Per-host secrets
  - path_regex: pandora\.yaml$
    key_groups:
      - age:
          - *fabian_yubikey_primary
          - *fabian_yubikey_backup
          - *pandora_host

  - path_regex: promethea\.yaml$
    key_groups:
      - age:
          - *fabian_yubikey_primary
          - *fabian_yubikey_backup
          - *promethea_host

  - path_regex: athenas\.yaml$
    key_groups:
      - age:
          - *fabian_yubikey_primary
          - *fabian_yubikey_backup
          - *athenas_host
EOF
```

### Step 4: Create Initial Secrets Files

```bash
# Create and encrypt common secrets
sops common.yaml
# Add your secrets in the editor, e.g.:
# cloudflare_api_token: "your-token-here"
# github_token: "ghp_xxx"

# Create host-specific secrets
sops pandora.yaml
sops promethea.yaml  
sops athenas.yaml
```

### Step 5: Push to Private Repo

```bash
cd ~/Documents/nixos-secrets
git add .
git commit -m "Initial secrets setup"
git remote add origin git@github.com:YOUR_USERNAME/nixos-secrets.git
git push -u origin main
```

### Step 6: Add to flake.nix

```nix
# In your main nixos-config flake.nix, add:
inputs = {
  # ... other inputs ...
  
  my-secrets = {
    url = "git+ssh://git@github.com/YOUR_USERNAME/nixos-secrets.git";
    flake = false;  # Not a flake, just files
  };
};
```

### Step 7: Reference Secrets in Modules

```nix
# In modules/secrets/default.nix
{ config, lib, inputs, ... }:
let hostname = config.hostname;
in {
  config.sops = {
    defaultSopsFile = "${inputs.my-secrets}/${hostname}.yaml";
    defaultSopsFormat = "yaml";
    
    # Common secrets available on all hosts
    secrets.cloudflare_api_token = {
      sopsFile = "${inputs.my-secrets}/common.yaml";
    };
    
    # Host-specific secrets use default file
    secrets.some_host_secret = {};
  };
}
```

### Usage After Setup

```bash
# Edit secrets (requires YubiKey)
sops ~/Documents/nixos-secrets/common.yaml

# Update secrets repo
cd ~/Documents/nixos-secrets && git add . && git commit -m "Update" && git push

# Rebuild NixOS (will fetch latest secrets)
sudo nixos-rebuild switch --flake ~/Documents/nixos-config#pandora
```

---

### Phase 5: Host Configuration Migration

#### [MODIFY] [hosts/pandora/default.nix](file:///home/fabian/Documents/nixos-config/hosts/pandora/default.nix) (renamed from configuration.nix)
```nix
{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware.nix
    ./overrides.nix  # Host-specific overrides
  ];

  # Global system options
  system = {
    hostname = "pandora";
    username = "fabian";
    
    # Enable features via options
    audio.enable = true;
    audio.lowLatency = true;
    bluetooth.enable = true;
    
    # Desktop environment
    desktop.niri = {
      enable = true;
      shell = "noctalia";
      monitors = [
        { name = "HDMI-A-2"; width = 1920; height = 1200; position = "0,0"; }
        { name = "DP-2"; width = 2560; height = 1440; refresh = 144; position = "1920,-200"; }
      ];
    };

    # Programs
    programs.gaming.enable = true;
    programs.development.enable = true;
    
    # Secrets
    secrets = {
      enable = true;
      keyType = "age-yubikey";
      sshKeyPaths = [ config.system.sshKeyPath ];
    };
  };

  # Home-manager configuration
  home-manager.users.${config.system.username} = import ./home.nix;

  # Host-specific packages
  environment.systemPackages = with pkgs; [ satisfactorymodmanager shotcut ];
}
```

#### [NEW] [hosts/pandora/overrides.nix](file:///home/fabian/Documents/nixos-config/hosts/pandora/overrides.nix)
```nix
{ config, lib, ... }: {
  # Override specific module defaults for this host
  system.audio.extraConfig = {
    # Crackling fix for this specific hardware
    boot.extraModprobeConfig = ''
      options snd_hda_intel power_save=0 power_save_controller=N
    '';
  };
}
```

---

### Phase 6: Updated flake.nix

#### [MODIFY] [flake.nix](file:///home/fabian/Documents/nixos-config/flake.nix)
```nix
{
  description = "Modular NixOS Configuration with Niri & Noctalia";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wayland compositor & shell
    niri.url = "github:sodiboo/niri-flake";  # Optional: community flake
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };

    # Optional: private secrets repo
    # my-secrets = {
    #   url = "git+ssh://git@github.com/yourusername/nixos-secrets.git";
    #   flake = false;
    # };
    
    # ... other inputs
  };

  outputs = inputs@{ self, nixpkgs, ... }: 
  let
    lib = import ./lib { inherit (nixpkgs) lib; inherit inputs; };
  in {
    nixosConfigurations = {
      pandora = lib.mkHost {
        hostname = "pandora";
        system = "x86_64-linux";
      };

      promethea = lib.mkHost {
        hostname = "promethea";
        system = "x86_64-linux";
      };

      athenas = lib.mkHost {
        hostname = "athenas";
        system = "x86_64-linux";
      };
    };
  };
}
```

---

## Module Options Reference

After implementation, hosts can toggle features like this:

```nix
# Enable/disable at the host level using config.* namespace
{
  # Core system
  audio.enable = true;
  audio.lowLatency = true;
  bluetooth.enable = true;
  
  # Desktop (mutually exclusive)
  desktop.niri.enable = true;
  # OR desktop.hyprland.enable = true;
  
  # Shell
  desktop.noctalia.enable = true;
  
  # Programs grouped by purpose
  programs.gaming.enable = true;     # Steam, Lutris, etc.
  programs.gaming.steam.enable = true;
  programs.development.enable = true; # Dev tools
  programs.browsers.zen.enable = true;
  
  # Services
  services.mullvad.enable = true;
  services.onepassword.enable = true;
  
  # Secrets
  secrets.enable = true;
}
```

### Example: Desktop Hosts with Profile

```nix
# hosts/pandora/default.nix
{ config, pkgs, ... }: {
  imports = [
    ../../profiles/desktop.nix  # Shared desktop config
    ./hardware.nix
  ];

  hostname = "pandora";

  # Override monitor config for this specific machine
  desktop.niri.monitors = [
    { name = "HDMI-A-2"; width = 1920; height = 1200; position = "0,0"; }
    { name = "DP-2"; width = 2560; height = 1440; refresh = 144; position = "1920,-200"; }
  ];

  # Pandora-specific packages (on top of desktop.nix packages)
  environment.systemPackages = with pkgs; [ 
    satisfactorymodmanager 
    shotcut 
  ];
}

# hosts/promethea/default.nix  
{ config, pkgs, ... }: {
  imports = [
    ../../profiles/desktop.nix  # Same shared config
    ./hardware.nix
  ];

  hostname = "promethea";

  # Laptop-specific monitor config
  desktop.niri.monitors = [
    { name = "eDP-1"; width = 1920; height = 1080; scale = 1.0; }
  ];
  
  # Laptop power management
  services.power-profiles-daemon.enable = true;
}
```

---

## Migration Strategy

### Step 1: Create new structure alongside existing
- Create `modules/`, `lib/`, `home-modules/` directories
- Keep existing `nixos/`, `home/` working during migration

### Step 2: Migrate core modules first
- Start with simple modules: `audio.nix`, `boot.nix`, `locale.nix`
- Test on one host (promethea as guinea pig?)

### Step 3: Add Niri + noctalia modules
- Implement desktop modules with all configuration options
- Test on a spare/VM system first

### Step 4: Migrate hosts one by one
- Keep old `configuration.nix` as backup
- Create new `default.nix` with options-based config
- Test thoroughly before removing old config

### Step 5: Unify secrets
- Generate host age keys from SSH keys
- Migrate athenas plaintext secrets to sops
- Create proper `.sops.yaml` with all recipients

---

## Verification Plan

### Automated Verification
Since NixOS configurations are declarative, the primary automated verification is:

```bash
# Build without activating - catches syntax and evaluation errors
nix build .#nixosConfigurations.pandora.config.system.build.toplevel --dry-run

# Build all hosts
for host in pandora promethea athenas; do
  nix build .#nixosConfigurations.$host.config.system.build.toplevel
done

# Check flake
nix flake check
```

### Manual Verification Steps

1. **Test in VM first** (for desktop changes):
   ```bash
   nixos-rebuild build-vm --flake .#pandora
   ./result/bin/run-pandora-vm
   ```

2. **Incremental deployment**:
   - Deploy to `promethea` first (least critical)
   - Verify sops-nix secrets decryption: `ls /run/secrets/`
   - Test Niri launches: login and check compositor is running
   - Test noctalia shell: verify bar/widgets appear

3. **Secrets verification**:
   ```bash
   # Test sops can decrypt with your key
   sops -d secrets/pandora.yaml
   
   # Check secret files exist after boot
   ls -la /run/secrets/
   ```

4. **User acceptance**: After deployment, please verify:
   - [ ] System boots correctly
   - [ ] Niri compositor runs without errors
   - [ ] Noctalia shell displays properly
   - [ ] All enabled programs/services are available
   - [ ] Secrets are accessible by services that need them

---

## Alternatives Considered

| Aspect | Current Choice | Alternative | Why Chosen |
|--------|---------------|-------------|------------|
| Options namespace | `config.*` | `system.*`, `my.*` | User preference, cleaner integration |
| Module structure | `modules/` directory | Keep `nixos/` naming | Clearer separation from NixOS defaults |
| Secrets strategy | Private repo + sops-nix | In-repo encrypted | Better security, user preference |
| Profiles | `profiles/desktop.nix` | Per-host duplication | Reduces duplication for pandora/promethea |
| Niri source | nixpkgs module | niri-flake | nixpkgs has stable package, can add flake later for bleeding edge |
