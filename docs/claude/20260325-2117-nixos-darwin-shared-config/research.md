# Research: Cross-Platform NixOS/nix-darwin Configuration with Dendritic Pattern

## Overview

This research covers building a unified Nix flake configuration that manages a Linux desktop, Linux laptop, and macOS laptop from a single repository. The architecture combines:

- **The Dendritic Pattern** — every `.nix` file (except `flake.nix`) is a flake-parts module, organized by feature rather than configuration class
- **flake-parts** — the module framework providing the top-level configuration layer
- **import-tree** — automatic recursive module discovery (no manual import lists)
- **wrapper-modules** — portable wrapped executables via the module system (cross-platform by nature)
- **home-manager** — user-level configuration shared across NixOS and nix-darwin
- **Niri** — scrollable-tiling Wayland compositor (Linux only)
- **Noctalia Shell** — desktop shell built on Quickshell/QML (Linux only)

The key insight: **wrapper-modules produce portable derivations** that work anywhere Nix runs, making them ideal for sharing application configuration between NixOS and nix-darwin without duplicating module definitions.

---

## Architecture

### The Dendritic Pattern

Created by Shahar "Dawn" Or (@mightyiam). Core rule: **every `.nix` file except entry points is a flake-parts module of the same type**.

**Principles:**

1. **Uniform file type** — eliminates the "what kind of file is this?" question
2. **Feature-oriented organization** — a single file (e.g., `git.nix`) contains NixOS config, home-manager config, darwin config, and packages for that feature
3. **No `specialArgs`** — values are shared via `let` bindings within files or flake-parts options
4. **`deferredModule` type** — lower-level configs (NixOS, home-manager, darwin) are stored as option values with merge semantics
5. **Automatic discovery** — `import-tree` replaces manual import lists; underscore-prefixed files/dirs are excluded

**How it differs from traditional approaches:**

| Aspect | Traditional | Dendritic |
|--------|------------|-----------|
| File types | Mixed (NixOS modules, HM modules, packages, overlays) | Uniform (all flake-parts modules) |
| Organization | By config class (`hosts/`, `home/`, `modules/`) | By feature (`ssh.nix`, `git.nix`) |
| Cross-cutting concerns | Scattered across directories | Consolidated in single files |
| Value sharing | `specialArgs`, `extraSpecialArgs` | `let` bindings, flake-parts options |
| Adding a feature | Touch multiple files in multiple directories | Create one file |
| Removing a feature | Edit multiple files | Delete one file (or prefix with `_`) |

### flake-parts

The module framework that provides the top-level configuration layer. Key concepts:

- **`perSystem`** — defines per-system (per-platform) outputs like packages, devShells, checks
- **`flake.*`** — defines flake-level outputs like `nixosConfigurations`, `darwinConfigurations`, `nixosModules`
- **`withSystem`** — bridges flake-level and per-system contexts (access `perSystem` values from flake-level code)
- **Module arguments** — `{ self, inputs, config, lib, ... }` at the top level; `{ pkgs, lib, self', inputs', ... }` inside `perSystem`

### import-tree

`github:vic/import-tree` — recursively imports all `.nix` files in a directory tree as flake-parts modules. Files prefixed with `_` are excluded. Directory structure is purely organizational — it has no semantic meaning to the system.

```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
  (inputs.import-tree ./modules);
```

### wrapper-modules

`github:BirdeeHub/nix-wrapper-modules` — creates wrapped executables through the module system. Instead of configuring programs via home-manager options or NixOS options, you produce a **standalone derivation** that bundles the program with its configuration.

**Why this matters for cross-platform:**

- Wrapped packages are portable — installable through any Nix mechanism
- No dependency on home-manager or NixOS module systems
- Same wrapped package works on NixOS, nix-darwin, or bare `nix profile install`
- The `.wrap` method uses the Nix module system for configuration, so you get type checking and merging

**Example — wrapping Niri:**

```nix
inputs.wrapper-modules.wrappers.niri.wrap {
  inherit pkgs;
  settings = {
    spawn-at-startup = [ (lib.getExe self'.packages.myNoctalia) ];
    input.keyboard.xkb.layout = "us";
    layout.gaps = 5;
    binds = {
      "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
      "Mod+Q".close-window = null;
    };
  };
};
```

**Important note from vimjoyer:** You must `inherit pkgs;` when using wrapper-modules.

### home-manager

Used for user-level configuration that doesn't fit the wrapper-modules model — shell configuration, git config, SSH config, XDG directories, etc. Integrates with both NixOS (as a NixOS module) and nix-darwin (as a darwin module).

In the dendritic pattern, home-manager modules are defined as `flake.modules.homeManager.<name>` option values using the `deferredModule` type, keeping them co-located with related NixOS/darwin config in the same feature file.

---

## Niri — Scrollable-Tiling Wayland Compositor

**GitHub:** <https://github.com/niri-wm/niri>
**Nix flake:** <https://github.com/sodiboo/niri-flake>

Windows arrange in columns on an infinite horizontal strip. Opening a new window never resizes existing windows — you scroll left/right to navigate. Dynamic workspaces are arranged vertically per monitor.

**Key features:**

- Infinite horizontal scrolling (inspired by PaperWM)
- Dynamic workspaces (vertical, per-monitor)
- Built-in screenshot UI, screencasting
- Gradient borders, animations with shader support
- Floating windows, window tabs
- Xwayland via xwayland-satellite
- Multi-monitor with mixed DPI, fractional scaling, NVIDIA support

**NixOS integration (two approaches):**

1. **niri-flake modules** — provides `niri.nixosModules.niri` and `niri.homeModules.niri` with declarative `programs.niri.settings`
2. **wrapper-modules** (video approach) — `inputs.wrapper-modules.wrappers.niri.wrap { ... }` produces a standalone wrapped package

The video uses approach 2 (wrapper-modules), which is more portable and fits the dendritic pattern better.

**Linux only** — Niri is a Wayland compositor and has no macOS equivalent. On macOS, the native window manager (or a tool like yabai/Aerospace) would be used instead.

---

## Noctalia Shell — Desktop Shell

**GitHub:** <https://github.com/noctalia-dev/noctalia-shell>
**Docs:** <https://docs.noctalia.dev/>

A desktop shell (not a compositor) built on Quickshell (Qt/QML). Provides: status bar, panels, app launcher, notifications, lock screen, OSD, theming, wallpapers, dock, and multi-monitor support.

**Key features:**

- Multi-compositor support: Niri, Hyprland, Sway, Scroll, Labwc, MangoWC
- Theming with dynamic wallpaper-based color generation
- ~100 available plugins
- IPC system (`noctalia-shell ipc call ...`)
- Wallhaven wallpaper integration

**NixOS setup (wrapper-modules approach from video):**

Generate settings snapshot:

```bash
nix run nixpkgs#noctalia-shell ipc call state all > ./modules/features/noctalia.json
```

Then wrap:

```nix
inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
  inherit pkgs;
  settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
};
```

**Prerequisites:** `networking.networkmanager.enable`, `hardware.bluetooth.enable`, `services.upower.enable`, `services.power-profiles-daemon.enable` (or `services.tuned.enable`).

**Linux only** — Noctalia is a Wayland shell and has no macOS equivalent.

---

## Cross-Platform Sharing Strategy

### What Can Be Shared (NixOS + nix-darwin)

| Layer | Mechanism | Examples |
|-------|-----------|----------|
| **Wrapped applications** | wrapper-modules (`perSystem`) | Terminal emulator, editor, shell tools — identical derivations on both platforms |
| **User dotfiles & config** | home-manager modules | Git, SSH, shell (zsh/fish/bash), XDG dirs, tmux, starship |
| **Development tools** | `perSystem` packages/devShells | Language toolchains, formatters, linters |
| **Nix settings** | Shared NixOS/darwin modules | `nix.settings`, `nix.gc`, experimental features |

### What Must Be Platform-Specific

| Platform | Examples |
|----------|----------|
| **NixOS only** | Boot loader, kernel, filesystem mounts, systemd services, Niri, Noctalia, Wayland/X11, audio (PipeWire), networking (NetworkManager), hardware-configuration.nix |
| **nix-darwin only** | macOS system preferences (`defaults write`), Homebrew cask integration, macOS services, Dock/Finder settings, security/privacy settings, Aerospace/yabai (if used) |

### What Varies Per Host (Same Platform)

| Concern | Examples |
|---------|----------|
| **Hardware** | Display scaling, GPU drivers, WiFi firmware, touchpad config |
| **Identity** | Hostname, user accounts, SSH keys |
| **Role** | Desktop gets gaming packages; laptop gets power management |

### Proposed Sharing Architecture

The dendritic pattern enables this naturally. A feature file like `git.nix` can define:

```nix
{ self, inputs, ... }: {
  # Shared home-manager module (works on both NixOS and darwin)
  flake.modules.homeManager.git = { pkgs, ... }: {
    programs.git = {
      enable = true;
      userName = "Hao";
      # ...
    };
  };
}
```

A feature like `niri.nix` only defines NixOS-specific config:

```nix
{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri.enable = true;
    # ...
  };

  perSystem = { pkgs, ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      # ...
    };
  };
}
```

Host files compose the appropriate modules:

```nix
# Linux desktop — uses NixOS + home-manager + niri + noctalia
self.nixosModules.niri
self.nixosModules.noctalia
self.homeModules.git
self.homeModules.shell

# macOS laptop — uses nix-darwin + home-manager (no niri/noctalia)
self.homeModules.git
self.homeModules.shell
```

---

## Proposed Directory Structure

```text
.
├── flake.nix                          # Entry point: inputs + import-tree
├── flake.lock
└── modules/
    ├── hosts/
    │   ├── linux-desktop/             # NixOS desktop
    │   │   ├── default.nix            # nixosConfigurations.linux-desktop
    │   │   ├── configuration.nix      # Host-specific NixOS module composition
    │   │   └── hardware.nix           # hardware-configuration.nix wrapper
    │   ├── linux-laptop/              # NixOS laptop
    │   │   ├── default.nix
    │   │   ├── configuration.nix
    │   │   └── hardware.nix
    │   └── macos-laptop/              # nix-darwin macOS
    │       ├── default.nix            # darwinConfigurations.macos-laptop
    │       └── configuration.nix      # Host-specific darwin module composition
    ├── features/
    │   ├── niri.nix                   # Niri compositor (Linux only, `nix run .#myNiri`)
    │   ├── noctalia.nix               # Noctalia shell (Linux only, `nix run .#myNoctalia`)
    │   ├── noctalia.json              # Noctalia settings snapshot
    │   ├── git.nix                    # Git config (shared via home-manager)
    │   ├── shell.nix                  # Shell config (`nix run .#myBash`)
    │   ├── terminal.nix               # Terminal emulator (`nix run .#myWezterm`)
    │   ├── editor.nix                 # Editor config (`nix run .#myNvim`)
    │   └── ssh.nix                    # SSH config (shared via home-manager)
    ├── os/
    │   ├── nixos.nix                  # Shared NixOS settings (boot, services, etc.)
    │   ├── darwin.nix                 # Shared darwin settings (defaults, services)
    │   └── nix-settings.nix           # Shared Nix daemon config (both platforms)
    └── users/
        └── hao.nix                    # User account + home-manager composition
```

---

## Key Flake Inputs

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  flake-parts.url = "github:hercules-ci/flake-parts";
  import-tree.url = "github:vic/import-tree";
  wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  nix-darwin = {
    url = "github:LnL7/nix-darwin";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # Optional: niri-flake if using its NixOS module instead of wrapper-modules
  # niri.url = "github:sodiboo/niri-flake";
  # noctalia = {
  #   url = "github:noctalia-dev/noctalia-shell";
  #   inputs.nixpkgs.follows = "nixpkgs";
  # };
};
```

---

## Edge Cases & Gotchas

1. **`inherit pkgs;` is required** when using wrapper-modules — the video author explicitly flagged this as a mistake in the video
2. **Niri and Noctalia are Linux-only** — the macOS host cannot use them; it needs a separate window management solution (or none)
3. **`perSystem` packages are platform-aware** — `pkgs.stdenv.hostPlatform.system` determines the platform, so Linux-only packages in `perSystem` need guards (e.g., `lib.optionalAttrs pkgs.stdenv.isLinux`)
4. **Noctalia requires nixpkgs unstable** for the latest Quickshell package
5. **Binary caches** — both Niri and Noctalia provide cachix caches to avoid long builds: `niri.cachix.org`, `noctalia.cachix.org`
6. **Noctalia settings export** — `noctalia-shell ipc call state all` requires a running Noctalia instance; initial config may need a bootstrap step
7. **home-manager integration** — can be loaded as a NixOS module (`home-manager.nixosModules.home-manager`) or a darwin module (`home-manager.darwinModules.home-manager`); the underlying home-manager modules themselves are shared
8. **import-tree and platform-specific files** — all files are imported on all platforms; platform-specific code must use guards or only define modules that are selectively composed in host configurations
9. **wrapper-modules vs home-manager modules** — wrapper-modules produce packages (derivations), while home-manager produces user environment config; they serve different purposes and can coexist
10. **`flake.modules.homeManager.<name>`** — this pattern requires the flake-parts `modules` option, which may need the `flake-parts-modules` or similar infrastructure; verify the exact API
11. **`nix run` standalone packages** — wrapper-modules packages exposed via `perSystem.packages` are automatically runnable with `nix run .#myNvim`, `nix run .#myBash`, etc. This is a major benefit of the wrapper-modules approach — you can test individual wrapped tools without building the full system.

---

## Testing Strategy (Without Overwriting the System)

Since the goal is to iterate safely without touching the existing Arch Linux installation, here are the available approaches:

### Build Without Applying (Primary Workflow)

```bash
# Build the full NixOS system closure — catches all evaluation and build errors
nix build .#nixosConfigurations.linux-desktop.config.system.build.toplevel

# Build the darwin config (on macOS)
nix build .#darwinConfigurations.macos-laptop.system

# Validate all flake outputs
nix flake check
```

This builds a `result` symlink but does not activate anything. Works on any system with Nix installed — **does not require NixOS or root**.

### Test Individual Packages with `nix run`

wrapper-modules packages can be tested standalone:

```bash
nix run .#myNvim          # test wrapped neovim
nix run .#myBash          # test wrapped bash with config
nix run .#myWezterm       # test wrapped terminal
nix run .#myNiri          # test wrapped compositor (Linux only)
```

This is the fastest feedback loop for individual features.

### QEMU VM Testing

Build a VM image of the full NixOS config and boot it:

```bash
# Build VM script
nixos-rebuild build-vm --flake .#linux-desktop
# Or on non-NixOS:
nix build .#nixosConfigurations.linux-desktop.config.system.build.vm

# Run it
./result/bin/run-nixos-vm
```

The VM can be configured with `virtualisation.vmVariant`:

```nix
virtualisation.vmVariant = {
  virtualisation = {
    memorySize = 4096;
    cores = 4;
    graphics = true;   # set false for headless + serial console
  };
};
```

**Requires KVM support** (`kvm-intel` or `kvm-amd` kernel module loaded). Delete `nixos.qcow2` to reset VM state between runs.

### NixOS Integration Tests (Automated)

Wire into the flake's `checks` output for CI:

```nix
checks.x86_64-linux.integration = pkgs.nixosTest {
  name = "config-integration-test";
  nodes.machine = { ... }: {
    imports = [ ./modules/hosts/linux-desktop/configuration.nix ];
  };
  testScript = ''
    machine.wait_for_unit("default.target")
    machine.succeed("which niri")
    machine.succeed("which noctalia-shell")
  '';
};
```

Run with `nix flake check` or `nix build .#checks.x86_64-linux.integration`.

### Docker/Podman Limitations

You **cannot** run a full NixOS system in Docker/Podman — NixOS requires systemd as PID 1. However, you can:

- Use `nixos/nix` Docker image to run `nix build` commands (validates the config builds)
- Use `pkgs.dockerTools.buildImage` to test application containers built with Nix

For full system testing, the **QEMU VM approach is strongly recommended** over Docker.

### Design Principle: Single-Command System Bootstrap

The configuration must be fully self-contained — a completely new machine should be set up with a single command that reads the Nix config and does everything. The QEMU VM serves as the proof: if it boots and works from scratch in a VM, it will work on bare metal.

This means:
- **No manual steps after `nixos-rebuild switch`** — all packages, services, user accounts, dotfiles, fonts, and desktop environment must be declarative
- **No imperative state** — avoid `nix-env -i`, manual `systemctl enable`, or post-install scripts that aren't captured in the config
- **The VM is the integration test** — building and booting the VM validates the entire config end-to-end
- **nix-darwin equivalent** — `darwin-rebuild switch --flake .` should fully configure a fresh macOS machine (after initial Nix install)

### Recommended Iteration Workflow

| Step | Command | What it catches |
|------|---------|----------------|
| 1. Validate | `nix flake check` | Syntax errors, evaluation errors, type mismatches |
| 2. Build | `nix build .#nixosConfigurations.*.config.system.build.toplevel` | Missing packages, build failures, dependency issues |
| 3. Test packages | `nix run .#myNvim` | Individual tool configuration issues |
| 4. VM test | `nixos-rebuild build-vm --flake .` | Full system runtime behavior (services, boot, desktop) |
| 5. Deploy | `nixos-rebuild switch --flake .` | Only when confident from steps 1-4 |

---

## Private Submodules & Public Repo Strategy

### The Problem

The directories in `~/.dotfiles` are Sourcehut submodules (`git@git.sr.ht:~hwrd/*`). Some are public, some are private. The NixOS config repo needs to be **public** for single-command bootstrap, but referencing private repos as dependencies would break builds for anyone without SSH access (including fresh machines before SSH keys are set up).

**Public repos** (visible at `git.sr.ht/~hwrd`): bashrc, bootstrap, ai-config, zmk-config, mise-config, git-config, nvim-config, sketchybar-config, waybar-config, sway-config, wezterm-config, foot-config, vivaldi-config, aerospace-config.

**Private repos** (not on public profile): scripts, inputrc, font-config, bat-config, firefox-config, chrome-config, mako-config, paru-config, polkit-config, fuzzel-config, kanshi-config, zshrc, senpai-config, direnv-config, aerc-config, and others.

### Solution: Inline Config Files, Not Submodule References

The NixOS config repo should contain the actual config files directly — not reference private submodules. This means:

1. **Copy config files into the NixOS repo** — bashrc customizations, nvim config, git config, scripts, etc. become part of the NixOS repo's directory tree
2. **The Sourcehut repos continue to exist** but are no longer dependencies — they're the historical source, not the runtime source
3. **The NixOS repo is fully self-contained** — `git clone` + `nixos-rebuild switch` works with no private dependencies

This fits the dendritic pattern naturally: each feature module (e.g., `modules/features/editor.nix`) co-locates its Nix wiring with its config files:

```text
modules/features/
├── editor.nix                    # Nix module: programs.neovim + extraPackages
├── editor/                       # Native config files (from ~/.dotfiles/nvim)
│   ├── init.lua
│   ├── lua/
│   │   ├── options.lua
│   │   ├── keymaps.lua
│   │   └── plugins/
│   └── after/
├── shell.nix                     # Nix module: programs.bash
├── shell/                        # Native config files (from ~/.dotfiles/bashrc)
│   ├── bashrc
│   ├── aliases
│   ├── customizations/
│   └── functions/
```

### Handling Previously-Private Configs

The configs from private Sourcehut repos (scripts, inputrc, bat, firefox, chrome, polkit, fuzzel, kanshi, direnv, etc.) will need to be included in the public NixOS repo for the single-command bootstrap to work. For most of these, this is fine — they're just preferences, not secrets.

**Review needed:** Before migrating, audit each private repo's contents for:
- **Actual secrets** (API keys, tokens, passwords) → handle with sops-nix
- **Work-specific config** (internal hostnames, org-specific git includes) → sops-encrypted overlay or separate private module
- **Just preferences that happen to be in private repos** (most of them) → safe to make public

For any config that must stay private but isn't a secret (e.g., you simply prefer it not be public), options include:
1. **sops-encrypted files** — overkill but works
2. **Private flake input** — a separate private repo with overrides, fetched via SSH (breaks single-command public bootstrap but could be optional)
3. **Local override** — a `_local/` directory (gitignored) that overlays settings at activation time

### Security Audit Results

A full audit of all private and public repos found **no hardcoded secrets** — all passwords and tokens are properly handled via `op` (1Password CLI). However, several files contain personal identifiers and work-specific config that need attention.

#### Must Encrypt or Exclude (MEDIUM risk)

| File | Issue | Action |
|------|-------|--------|
| `aerc/accounts.conf` | Full email account config (name, email, provider, 1Password item names) | **sops-encrypt** |
| `senpai/senpai.scfg` | IRC identity (real name, nicknames, chat token reference) | **sops-encrypt** |
| `git/[EMPLOYER_PROJECT].config` | Employer-specific git alias (release candidate workflow) | **Exclude** from public repo |
| `git/config` lines 5-16 | Employer name (`[EMPLOYER]`, `[EMPLOYER_PROJECT]`) in URL shortcuts and includeIf | **Move** to `~/.gitconfig.secret` (already has `[include]` for this) |
| `git/config` lines 9-13 | `pushInsteadOf` with personal GitHub/Sourcehut usernames | **Move** to `~/.gitconfig.secret` |
| `bashrc/customizations/darwin.bash` line 5 | `$HOME/Projects/[EMPLOYER_PROJECT]/toolbox` employer project path | **Redact** — remove or move to host-specific secret |
| `scripts/hosts/[REMOVED_HOST]/synergy` | Home LAN IP `[HOME_IP]` and hostname | **sops-encrypt** or parameterize |
| `scripts/linux/romm` lines 36-43 | Home server IP, ports, SSH username, directory paths | **sops-encrypt** or parameterize |
| `zsh/zshrc` line 10 | macOS username `[MACOS_USER]` in path | **Redact** — use `$HOME` |
| `nvim/lua/plugins/conform.lua` line 79 | `github.com/hahuang65`, `git.sr.ht/~hwrd` in goimports grouping | **Parameterize** or accept as public |
| `sketchybar/install.sh` line 5 | `com.[MACOS_USER].volume-listener` plist identifier | **Redact** — use generic identifier |
| `scripts/shared/srht_scripts/srht-repo-new` line 80 | Hardcoded Sourcehut username `~hwrd` | **Parameterize** with env var |

#### Must Remove Entirely

| Files | Issue | Action |
|-------|-------|--------|
| All `.builds/mirror.yml` across all repos | Sourcehut CI secret UUIDs + email `hao@hwrd.me` | **Remove** all `.builds/` dirs, add to `.gitignore` |

#### Accept as Public (Decision Required)

These are personal identifiers that are common in dotfiles repos but link to real identity:
- Email addresses: `hao@hwrd.me`, `h.huang65@gmail.com`
- GitHub username: `hahuang65`
- Sourcehut username: `~hwrd`
- Git branch prefix: `hh/`
- Full name: `Howard Huang`

**These are likely fine** for a public dotfiles/NixOS repo (thousands of public dotfiles repos contain this info), but the user should explicitly confirm they're comfortable with this exposure.

#### Safe to Publish (LOW risk)

Hardware-specific config (Dell touchpad ID, monitor profiles), 1Password polkit rules, Zscaler scripts, example IPs in documentation, `~/.secrets.sh` sourcing pattern — all safe.

---

## Secrets Management with sops-nix

### Overview

**sops-nix** (`github:Mic92/sops-nix`) integrates Mozilla's SOPS with NixOS, nix-darwin, and home-manager. Encrypted secrets live in the public repo — values are encrypted, keys (names) remain in plaintext. Secrets are decrypted at system activation time and placed in `/run/secrets/` (tmpfs on NixOS, never hits disk).

### Flake Input

```nix
inputs.sops-nix = {
  url = "github:Mic92/sops-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Modules:
- **NixOS:** `sops-nix.nixosModules.sops`
- **nix-darwin:** `sops-nix.darwinModules.sops`
- **home-manager:** `sops-nix.homeManagerModules.sops`

### Encryption with age Keys

age is the recommended backend — simpler than GPG, no key expiry, and can derive keys from SSH host keys.

```bash
# Generate a personal age key (for editing secrets on your workstation)
age-keygen -o ~/.config/sops/age/keys.txt

# Derive a host's age public key from its SSH host key
ssh-keyscan myhost | ssh-to-age
```

### `.sops.yaml` (lives at repo root)

```yaml
keys:
  - &user_hao age1xxxxxxxxxx      # personal editing key
  - &host_desktop age1yyyyyyyyyy  # linux desktop SSH host key
  - &host_laptop age1zzzzzzzzzz   # linux laptop SSH host key
  - &host_mac age1aaaaaaaaaaaa    # macOS laptop age key

creation_rules:
  - path_regex: secrets/common\.yaml$
    key_groups:
      - age: [*user_hao, *host_desktop, *host_laptop, *host_mac]

  - path_regex: secrets/nixos\.yaml$
    key_groups:
      - age: [*user_hao, *host_desktop, *host_laptop]

  - path_regex: secrets/darwin\.yaml$
    key_groups:
      - age: [*user_hao, *host_mac]

  - path_regex: secrets/home\.yaml$
    key_groups:
      - age: [*user_hao, *host_desktop, *host_laptop, *host_mac]
```

### Secrets File Organization

```text
secrets/
├── common.yaml       # shared across all hosts (DNS tokens, etc.)
├── nixos.yaml        # NixOS-specific (VPN keys, service creds)
├── darwin.yaml       # darwin-specific
└── home.yaml         # user-level secrets (git tokens, API keys)
```

Create/edit with `sops secrets/common.yaml` — opens `$EDITOR` with decrypted YAML, re-encrypts on save.

### Using Secrets in NixOS Modules

```nix
# In a feature module
sops.secrets."wireguard_private_key" = {
  sopsFile = ../../secrets/nixos.yaml;
};

services.wireguard.interfaces.wg0 = {
  privateKeyFile = config.sops.secrets.wireguard_private_key.path;
  # resolves to /run/secrets/wireguard_private_key
};
```

### Environment Variable Secrets (Current Bash Approach)

The current approach of sourcing a secret file with `export` statements in bash **can be preserved** with sops-nix. Two options:

**Option A: sops-nix decrypts the env file, bash sources it**

```nix
# Encrypt the env file (contains lines like: export API_KEY=secret123)
sops.secrets."env_secrets" = {
  sopsFile = ../../secrets/env.yaml;  # or format = "binary" for a raw file
  owner = "hao";
  path = "/run/secrets/env_secrets";
};
```

Then in bashrc:
```bash
# Source decrypted env secrets if available
[[ -f /run/secrets/env_secrets ]] && source /run/secrets/env_secrets
```

**Option B: sops-nix templates compose env vars from individual secrets**

```nix
sops.secrets."github_token" = {};
sops.secrets."cloudflare_token" = {};

sops.templates."env_secrets" = {
  content = ''
    export GITHUB_TOKEN=${config.sops.placeholder."github_token"}
    export CLOUDFLARE_API_TOKEN=${config.sops.placeholder."cloudflare_token"}
  '';
  owner = "hao";
};
```

Then in bashrc:
```bash
[[ -f /run/secrets-rendered/env_secrets ]] && source /run/secrets-rendered/env_secrets
```

Option B is preferred because individual secrets can also be used by systemd services, and you get fine-grained access control.

### home-manager Secrets (User-Level)

For secrets that don't need root (personal API tokens, etc.):

```nix
# In home-manager config
sops = {
  defaultSopsFile = ../../secrets/home.yaml;
  age.keyFile = "/home/hao/.config/sops/age/keys.txt";

  secrets."github_token" = {};
  secrets."netrc" = {
    path = "${config.home.homeDirectory}/.netrc";
    mode = "0600";
  };
};
```

On Linux, home-manager secrets land in `$XDG_RUNTIME_DIR/secrets.d/` (tmpfs). On macOS, they land in `~/.config/sops-nix/secrets/`.

### Bootstrapping a New Machine

The chicken-and-egg: the machine needs its age key to decrypt secrets, but the age key isn't yet on the machine.

**For NixOS (SSH host key approach):**
1. Install minimal NixOS (generates `/etc/ssh/ssh_host_ed25519_key`)
2. Get the machine's age public key: `ssh-keyscan newhost | ssh-to-age`
3. Add to `.sops.yaml`, run `sops updatekeys --yes secrets/*.yaml`
4. Commit, deploy: `nixos-rebuild switch --flake .#newhost`

**For nix-darwin:**
1. Install Nix + nix-darwin
2. Generate age key: `age-keygen -o ~/.config/sops/age/keys.txt`
3. Add public key to `.sops.yaml`, run `sops updatekeys --yes secrets/*.yaml`
4. Deploy: `darwin-rebuild switch --flake .#mymac`

The bootstrapping step (placing the age key) is the **one manual step** before the single-command deploy works. After that, everything is declarative.

### NixOS vs nix-darwin Differences

| Aspect | NixOS | nix-darwin |
|--------|-------|------------|
| Module | `nixosModules.sops` | `darwinModules.sops` |
| Secret path | `/run/secrets/` (tmpfs) | `/run/secrets/` (regular dir) |
| Age key source | SSH host key (auto) | Manual `age.keyFile` |
| `neededForUsers` | Supported (early boot) | Not applicable |
| Templates | Supported | Supported |

---

## Key References

- **Dendritic pattern:** <https://github.com/mightyiam/dendritic>
- **Dendritic pattern discussion:** <https://discourse.nixos.org/t/the-dendritic-pattern/61271>
- **flake-parts:** <https://flake.parts/>
- **import-tree:** <https://github.com/vic/import-tree>
- **wrapper-modules:** <https://github.com/BirdeeHub/nix-wrapper-modules>
- **wrapper-modules docs:** <https://birdeehub.github.io/nix-wrapper-modules/md/intro.html>
- **Niri:** <https://github.com/niri-wm/niri>
- **niri-flake:** <https://github.com/sodiboo/niri-flake>
- **Noctalia Shell:** <https://github.com/noctalia-dev/noctalia-shell>
- **Noctalia docs:** <https://docs.noctalia.dev/>
- **Vimjoyer's config:** <https://github.com/vimjoyer/nixconf>
- **Vimjoyer's template:** <https://github.com/vimjoyer/flake-parts-wrapped-template>
- **Vimjoyer's video supplement:** <https://www.vimjoyer.com/vid79-parts-wrapped>
- **Dendritic design guide:** <https://github.com/Doc-Steve/dendritic-design-with-flake-parts>
- **Dendrix community project:** <https://github.com/vic/dendrix>
- **Community configs:** <https://github.com/TimothyBear11/nixtalia>, <https://github.com/JulianPasco/nocturi>
- **sops-nix:** <https://github.com/Mic92/sops-nix>
- **Previous nixos-config (sops reference):** <https://github.com/hahuang65/nixos-config>

---

## Existing Dotfiles (`~/.dotfiles`)

This is a greenfield NixOS config, but there is a mature set of dotfiles at `~/.dotfiles` organized by application/feature that will be migrated into Nix modules. The dotfiles already support both Linux (Arch-based) and macOS via conditional loading and platform-specific directories.

### Directory Inventory

| Directory | Purpose | Migration Target | Complexity |
|-----------|---------|-----------------|------------|
| `bashrc/` | Bash shell config (63-line entrypoint, 22 customizations, 8 functions, deferred aliases) | home-manager `programs.bash` + custom scripts | **High** — complex source ordering, deferred aliases, platform conditionals |
| `nvim/` | Neovim config (init.lua, 40+ plugins via lazy.nvim, LSP, DAP, snippets, Catppuccin theme) | home-manager `programs.neovim` or wrapper-modules | **High** — 40+ plugins with lazy loading, mason tool installs, custom keymaps |
| `scripts/` | 40+ utility scripts organized into `shared/`, `linux/`, `darwin/`, `hosts/` | home-manager `home.packages` (wrapped scripts) or `perSystem` packages | **High** — platform-conditional scripts, complex tools like `lv` (~400 lines) |
| `git/` | Git config with delta pager, 30+ aliases, conditional includes, URL shortcuts | home-manager `programs.git` | Medium |
| `sway/` | Sway WM config (Catppuccin, named workspaces, lid switch, scratchpad) | NixOS module (disabled, kept for reference) | Medium |
| `waybar/` | Status bar with custom scripts (clock, weather, audio, media, network, battery) | NixOS module (disabled, kept for reference) | Medium |
| `foot/` | Lightweight terminal (Maple Mono font, Catppuccin, custom URL regex, keybinds) | home-manager or wrapper-modules | Low |
| `wezterm/` | Terminal with Lua config (Tokyo Night, platform-specific decorations, font fallbacks) | home-manager or wrapper-modules | Low |
| `aerospace/` | macOS tiling WM (workspace tracking, sketchybar integration) | nix-darwin module | Low |
| `sketchybar/` | macOS status bar (Bash/Swift plugins) | nix-darwin module | Low |
| `ai/` | Claude Code rules, skills, agents, commands | Symlinked or copied (not Nix-managed) | Low |
| `bat/` | Bat syntax highlighter config | home-manager `programs.bat` | Low |
| `direnv/` | Direnv config | home-manager `programs.direnv` | Low |
| `mise/` | Tool version manager (Go, Node, Python, Ruby defaults) | home-manager `programs.mise` or Nix devShells | Low |
| `zsh/` | Minimal zsh config (15 lines, vi mode) | home-manager `programs.zsh` | Low |
| `inputrc/` | Readline config | home-manager `programs.readline` | Low |
| `fuzzel/` | App launcher | home-manager or wrapper-modules | Low |
| `kanshi/` | Display manager | NixOS module | Low |
| `mako/` | Notification daemon | NixOS module (replaced by Noctalia) | Low |
| `font/` | Font files | `fonts.packages` in NixOS/darwin | Low |
| `bootstrap/` | Install scripts (Brewfile, Parufile, configure) | Replaced by Nix flake entirely | N/A |

### Key Migration Challenges

#### 1. Bash Configuration (`bashrc/`)

The bash setup has a specific source order that matters:

1. Helper functions (`_*.bash`) loaded first
2. Regular functions loaded next
3. Aliases loaded (deferred via `PROMPT_COMMAND` for startup speed)
4. Customizations loaded in alphabetical order (except `direnv.bash` loads last)

Key features to preserve:

- **Deferred alias evaluation** — aliases are set up lazily on first prompt to reduce startup time
- **Platform conditionals** — `darwin.bash` and `linux.bash` load OS-specific settings
- **Tool detection** — `_exists()` / `alias_available()` checks before aliasing (e.g., `bat` for `cat`)
- **Benchmarking** — `BENCHMARK=1` env var profiles startup time
- **FZF integration** — custom preview bindings for both platforms
- **History tuning** — 500K size, timestamps, immediate append, erasedups
- **Editor defaults** — nvim preferred, with fallback chain and emacs-mode detection inside vim terminal

**home-manager approach:** Keep all bash code in `.bash` files — no inlining into `initExtra`/`bashrcExtra` fields. Use `home.file` to place the customization, function, and alias files into the expected locations, then use a minimal `initExtra` that simply sources the entrypoint (`source ~/.config/bash/bashrc` or equivalent). This preserves the existing file structure for easy editing outside of Nix. **This same principle applies to all features** — config should live in native config files (`.lua`, `.toml`, `.ini`, etc.), not inlined in Nix strings.

#### 2. Neovim (`nvim/`)

A full Lua-based config with 40+ plugins managed by `lazy.nvim`. Key characteristics:

- **Plugin manager:** lazy.nvim (event-based loading, dependencies, build steps)
- **LSP:** lspconfig + mason for auto-installing language servers to `~/.local/share/mise/shims/`
- **Completion:** blink.cmp + luasnip
- **Theme:** Catppuccin Mocha
- **Testing:** neotest with per-language adapters
- **DAP:** Debug adapter protocol setup with custom utilities
- **AI:** Claude Code + OpenCode integration plugins
- **Notebooks:** Quarto + Molten for Jupyter-style execution

**Migration options:**

1. **Symlink as-is** — use `xdg.configFile."nvim".source = ./nvim` to place the entire config directory. Simplest, preserves lazy.nvim's package management.
2. **wrapper-modules** — wrap neovim with config baked in. Portable but complex.
3. **home-manager `programs.neovim`** — full Nix-native plugin management. Most integrated but requires converting all 40+ plugins to Nix expressions.

**Recommendation:** Option 1 (symlink) initially. The lazy.nvim ecosystem is complex enough that a full Nix conversion is a separate project.

**Prior experience note:** In a previous NixOS config ([hahuang65/nixos-config](https://github.com/hahuang65/nixos-config/tree/main/home/neovim)), a simple symlink wasn't sufficient — the config required a Nix-managed wrapper with `github-packages/` overlays and `tool_configs/` for LSP/formatter integration. The main issues with plain symlinks on NixOS are:
- Mason-installed binaries (LSPs, formatters) may not work due to NixOS's non-FHS layout (no `/usr/lib`, dynamic linker mismatches)
- Treesitter parsers compiled by nvim-treesitter may fail to link against system libraries
- Plugin build steps (`make`, `cargo build`) may need Nix-provided toolchains

**Mitigation for symlink approach:** Use `programs.neovim.enable = true` with `extraPackages` to provide LSP servers, formatters, and build tools on PATH via Nix, while keeping the Lua config files symlinked as-is. This avoids the full Nix plugin conversion while solving the FHS/binary issues. Mason can be configured to skip installing tools that are already on PATH.

#### 3. Scripts (`scripts/`)

40+ scripts organized by platform:

- `shared/` — cross-platform (40+ tools: `dots`, `lv`, `bb`, `each`, AWS tools, media tools)
- `linux/` — Linux-specific (`bar`, `lock`, `notepad`, `pkg`, `vpn`, `wifi`, `scratchpad`)
- `darwin/` — macOS-specific (`pkg`, `notepad`, `scratchpad`, `kill-zscaler`)
- `hosts/` — host-specific overrides

**Migration approach:** Add `shared/` and platform-appropriate directory to `$PATH` via home-manager. Scripts remain as files, added to `home.packages` as wrapped scripts or simply placed on PATH via `home.file` + `home.sessionPath`.

### Sway/Waybar Migration Plan

The user wants to **replace Sway with Niri** and **Waybar with Noctalia** as the primary setup, but keep Sway/Waybar configured but disabled for fallback:

- Create `modules/features/niri.nix` — primary compositor (active)
- Create `modules/features/noctalia.nix` — primary shell/bar (active)
- Create `modules/features/sway.nix` — legacy compositor (available but not default session)
- Create `modules/features/waybar.nix` — legacy bar (available but not auto-started)

This allows switching back to Sway if Niri has issues, without reconfiguring.

### Cross-Platform Dotfile Sharing Summary

| Dotfile | Mechanism | Shared? |
|---------|-----------|---------|
| bashrc | home-manager `programs.bash` | Yes — platform conditionals already built in |
| nvim | `xdg.configFile` symlink | Yes — identical on both platforms |
| git | home-manager `programs.git` | Yes — conditional includes handle org-specific config |
| scripts | `home.sessionPath` + `home.file` | Partially — `shared/` is shared, `linux/`/`darwin/` are platform-specific |
| foot | home-manager or wrapper-modules | Linux only |
| wezterm | wrapper-modules or `xdg.configFile` | Yes — already handles platform differences in Lua |
| sway/waybar | NixOS modules (disabled) | Linux only |
| aerospace/sketchybar | nix-darwin modules | macOS only |
| fonts | `fonts.packages` | Yes — same fonts on both |
| bat/direnv/mise/inputrc | home-manager programs | Yes |
