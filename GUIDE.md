# NixOS Configuration Guide

## Architecture Overview

```
flake.nix                    ← Entry point: defines inputs & hosts
├── lib/default.nix          ← mkHost helper (wires modules + host config)
├── modules/                 ← NixOS modules (system-level, shared by all hosts)
│   ├── default.nix          ← Global options (hostname, username, locale, git, etc.)
│   ├── core/                ← Boot, audio, bluetooth, locale, networking, nix, ssh, users, utils
│   ├── desktop/             ← Niri compositor, Noctalia shell
│   ├── programs/            ← Browsers, development, gaming
│   ├── services/            ← Mullvad, 1Password, GNOME Keyring
│   ├── hardware/            ← AMD, Nvidia GPU support
│   └── secrets/             ← Secrets management
├── profiles/                ← Shared presets that set module options
│   ├── desktop.nix          ← Enables audio, bluetooth, niri, browsers, gaming, etc.
│   └── server.nix           ← Minimal headless config
├── hosts/                   ← Per-machine configurations
│   ├── pandora/             ← Main Desktop
│   ├── promethea/           ← Laptop
│   └── athenas/             ← Homelab Server
├── home/                    ← Home Manager configurations (user-level)
│   ├── desktop.nix          ← Shared HM base for all desktop hosts
│   ├── programs/            ← Per-app HM configs (git, kitty, niri, zen, discord, etc.)
│   ├── system/              ← User-level system configs (mime, udiskie, libinput)
│   └── scripts/             ← Custom scripts
└── homelab/                 ← Self-hosted services
```

### Design Principles

| Principle | How |
|-----------|-----|
| **DRY** | Shared config lives in `profiles/` (NixOS) and `home/desktop.nix` (HM). Hosts only contain host-specific overrides. |
| **NixOS vs HM** | System-level concerns (kernel, services, display manager) stay in `modules/`. User-level concerns (dotfiles, packages, shell config) go in `home/`. |
| **Typed options** | Modules define options with `lib.mkOption` / `lib.mkEnableOption`. Profiles set those options. This decouples "what" from "how". |
| **osConfig bridge** | HM configs read NixOS-level values via `osConfig.*` (e.g., `osConfig.username`, `osConfig.git.email`). |

---

## How To: Add a New Device

### 1. Create the host directory

```
hosts/
└── myhost/
    ├── default.nix
    ├── hardware-configuration.nix
    └── home.nix
```

Generate `hardware-configuration.nix` on the target machine:

```bash
nixos-generate-config --show-hardware-config > hosts/myhost/hardware-configuration.nix
```

### 2. Write `default.nix`

Pick a profile (`desktop.nix` or `server.nix`) and add host-specific overrides:

```nix
# hosts/myhost/default.nix
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ../../profiles/desktop.nix  # or ../../profiles/server.nix
    ./hardware-configuration.nix
  ];

  hostname = "myhost";
  username = "fabian";

  # Host-specific overrides
  desktop.niri.monitors = [
    { name = "HDMI-A-1"; width = 1920; height = 1080; refresh = 60; }
  ];

  home-manager.users.${config.username} = import ./home.nix;

  system.stateVersion = "25.05";  # Set to your install version, never change
}
```

### 3. Write `home.nix`

Import the shared desktop base and add host-specific packages:

```nix
# hosts/myhost/home.nix
{ pkgs, osConfig, ... }:
{
  imports = [
    ../../home/desktop.nix  # shared programs, shell, polkit, etc.
  ];

  home = {
    username = osConfig.username;
    homeDirectory = "/home/${osConfig.username}";
    packages = with pkgs; [
      # host-specific packages here
    ];
    stateVersion = "25.05";
  };
}
```

For a **server** host, skip `home/desktop.nix` and import only what you need:

```nix
{ pkgs, osConfig, ... }:
{
  imports = [
    ../../home/programs/ssh
    ../../home/programs/git
  ];
  home = {
    username = osConfig.username;
    homeDirectory = "/home/${osConfig.username}";
    packages = with pkgs; [ btop fastfetch ];
    stateVersion = "25.05";
  };
  programs.home-manager.enable = true;
}
```

### 4. Register in `flake.nix`

```nix
nixosConfigurations = {
  # ...existing hosts...
  myhost = myLib.mkHost {
    hostname = "myhost";
    system = "x86_64-linux";
  };
};
```

### 5. Build and deploy

```bash
nix flake check          # syntax validation
nh os build .            # test build
nh os switch .           # apply (run on target machine)
```

---

## How To: Add a New Program

### User-level program (Home Manager)

Create a new directory under `home/programs/`:

```
home/programs/myapp/
└── default.nix
```

```nix
# home/programs/myapp/default.nix
{ pkgs, ... }:
{
  programs.myapp = {
    enable = true;
    # settings...
  };

  # Or if HM doesn't have a module, just install the package:
  # home.packages = [ pkgs.myapp ];

  # Or manage a config file manually:
  # xdg.configFile."myapp/config.toml".text = ''
  #   [settings]
  #   key = "value"
  # '';
}
```

Then import it where needed:

- **All desktops** → add to `home/desktop.nix` imports
- **One host only** → add to that host's `home.nix` imports
- **Server too** → add to `hosts/athenas/home.nix` imports

### System-level program (NixOS module)

For programs that need system-level access (e.g., Docker, Steam, display managers):

```nix
# modules/programs/myservice.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.myservice;
in {
  options.programs.myservice = {
    enable = lib.mkEnableOption "My Service";
  };

  config = lib.mkIf cfg.enable {
    # System-level config here
    environment.systemPackages = [ pkgs.myservice ];
  };
}
```

Then:
1. Import it in `modules/programs/default.nix`
2. Enable it in a profile or host: `programs.myservice.enable = true;`

### Decision guide: NixOS module vs HM?

| Goes in NixOS module | Goes in Home Manager |
|---------------------|----------------------|
| Needs root / systemd system services | User dotfiles & config |
| Kernel modules, boot params | Shell aliases, env vars |
| System users/groups (e.g., Docker) | GUI app packages |
| Firewall rules | Browser extensions/policies |
| Display manager, compositor setup | Compositor keybinds & layout |
| PAM / polkit policies | User systemd services |

---

## How To: Add a New Service

### User service (Home Manager)

```nix
# In any HM config file
systemd.user.services.my-daemon = {
  Unit.Description = "My Daemon";
  Service = {
    ExecStart = "${pkgs.my-daemon}/bin/my-daemon";
    Restart = "on-failure";
  };
  Install.WantedBy = [ "default.target" ];
};
```

### System service (NixOS module)

Create a module under `modules/services/`:

```nix
# modules/services/myservice.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.services.myservice;
in {
  options.services.myservice = {
    enable = lib.mkEnableOption "My Service";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.myservice = {
      description = "My Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.myservice}/bin/myservice";
        Restart = "always";
      };
    };
  };
}
```

Then import in `modules/services/default.nix` and enable in a profile or host.

### Homelab service (athenas only)

Add under `homelab/services/` and register in `homelab/services/default.nix`. These use the `homelab.*` option namespace. See existing services (adguard, caddy, homepage) for patterns.

---

## How To: Add a Flake Input

For external modules (e.g., a new compositor, tool, or overlay):

### 1. Add to `flake.nix` inputs

```nix
inputs = {
  # ...existing...
  my-tool = {
    url = "github:author/my-tool";
    inputs.nixpkgs.follows = "nixpkgs";  # pin to our nixpkgs
  };
};
```

### 2. Access in modules

The `inputs` attrset is passed through `specialArgs` (see `lib/default.nix`), so any module can use it:

```nix
{ inputs, pkgs, ... }:
{
  imports = [ inputs.my-tool.nixosModules.default ];
  # or
  home.packages = [ inputs.my-tool.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
```

### 3. Add cachix substituter (if available)

Add to `modules/core/nix.nix` → `nix.settings.substituters` and `trusted-public-keys`.

---

## How To: Create a New Profile

Profiles are sets of option values. They don't define options — they set them.

```nix
# profiles/workstation.nix
{ config, lib, pkgs, ... }:
{
  audio.enable = true;
  bluetooth.enable = true;
  desktop.niri.enable = true;

  programs.development = {
    enable = true;
    docker.enable = true;
  };
}
```

A host imports the profile: `imports = [ ../../profiles/workstation.nix ];`

---

## Key Options Reference

### Global (`modules/default.nix`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hostname` | str | — | Machine name |
| `username` | str | `"fabian"` | Primary user |
| `configDirectory` | str | auto | Path to this repo |
| `locale.keyboardLayout` | str | `"de"` | Keyboard layout |
| `locale.timeZone` | str | `"Europe/Berlin"` | Timezone |
| `git.username` | str | `"furilo"` | Git user |
| `git.email` | str | — | Git email |
| `autoUpgrade` | bool | `false` | Auto system upgrades |
| `autoGarbageCollector` | bool | `true` | Auto nix GC |

### Desktop (`modules/desktop/`)

| Option | Type | Default |
|--------|------|---------|
| `desktop.niri.enable` | bool | `false` |
| `desktop.niri.shell` | enum | `"noctalia"` |
| `desktop.niri.layout.gaps` | int | `8` |
| `desktop.niri.monitors` | list | `[]` |
| `desktop.noctalia.enable` | bool | `false` |

### Programs (`modules/programs/`)

| Option | Type | Default |
|--------|------|---------|
| `programs.gaming.enable` | bool | `false` |
| `programs.development.enable` | bool | `false` |
| `programs.development.docker.enable` | bool | `false` |
| `programs.browsers.zen.enable` | bool | `false` |
| `programs.browsers.brave.enable` | bool | `false` |

### Services (`modules/services/`)

| Option | Type | Default |
|--------|------|---------|
| `services.mullvad.enable` | bool | `false` |
| `services.onepassword.enable` | bool | `false` |
| `services.gnomeKeyring.enable` | bool | `false` |

---

## Common Commands

```bash
nix flake check          # Validate syntax & evaluation
nix flake update         # Update all inputs
nh os build .            # Build without switching
nh os switch .           # Build and switch
nh clean --keep 5        # Garbage collect old generations
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| New file not found by flake | `git add <file>` — flakes only see git-tracked files |
| Option conflict between NixOS and HM | Use `lib.mkForce` or `lib.mkDefault` to set priority |
| Package in both `environment.systemPackages` and `home.packages` | Remove from system level — prefer HM for user packages |
| `osConfig` not available | Only works in HM configs when using NixOS module integration |
| Build fails with "infinite recursion" | Check for circular imports between modules |
