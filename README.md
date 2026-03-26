# NixOS Configuration

Cross-platform system configuration using the [dendritic pattern](https://github.com/mightyiam/dendritic) with [flake-parts](https://flake.parts/) and [import-tree](https://github.com/vic/import-tree).

Manages a Linux desktop, Linux laptop, and macOS laptop from a single repository. [Niri](https://github.com/niri-wm/niri) + [Noctalia](https://github.com/noctalia-dev/noctalia-shell) for the Linux desktop environment.

## Hosts

| Host | Platform | Description |
|------|----------|-------------|
| `endor` | NixOS | Desktop (bluetooth, podman) |
| `bespin` | NixOS | Laptop (power management, podman) |
| `macos` | nix-darwin | macOS laptop |
| `vm` | NixOS | QEMU test VM |

## Setting Up a New NixOS System

The system works without secrets — you can deploy first and set up secrets later.

1. Install NixOS (minimal installation is fine).

2. Clone this repository:

       git clone https://git.sr.ht/~hwrd/nixos-config
       cd nixos-config

3. Replace the hardware configuration for your host. Run `nixos-generate-config --show-hardware-config` on the target machine and update the corresponding `modules/hosts/<host>/hardware.nix`.

4. Deploy:

       sudo nixos-rebuild switch --flake .#endor

5. Set up secrets when ready (see [Secrets](#secrets) below).

## Setting Up macOS

1. Install [Nix](https://nixos.org/download/) and [nix-darwin](https://github.com/LnL7/nix-darwin).

2. Clone this repository.

3. Deploy:

       darwin-rebuild switch --flake .#macos

4. Set up secrets when ready (see [Secrets](#secrets) below).

## Testing in a VM

Build and boot a QEMU VM without touching your current system:

    nix build .#nixosConfigurations.vm.config.system.build.vm
    ./result/bin/run-vm-vm

Delete `vm.qcow2` to reset VM state between runs. The VM auto-logs in to a shell. KVM is required for reasonable performance.

## Running Individual Packages

Wrapped packages can be run standalone without building the full system.

From a local clone:

    nix run .#nvim         # Neovim with full config
    nix run .#wezterm      # WezTerm terminal
    nix run .#niri         # Niri desktop (compositor + Noctalia shell)

Directly from GitHub (no clone needed):

    nix run github:hahuang65/nixos-config#nvim
    nix run github:hahuang65/nixos-config#wezterm
    nix run github:hahuang65/nixos-config#niri

## Architecture

Every `.nix` file under `modules/` is a [flake-parts](https://flake.parts/) module. Files are organized by feature, not by configuration class. A single file can define NixOS config, nix-darwin config, and home-manager config for the same feature.

```
modules/
├── systems/           # Platform-level shared config
│   ├── nixos.nix      # Shared NixOS settings
│   ├── darwin.nix     # Shared nix-darwin settings
│   ├── desktop.nix    # Graphical session (niri, noctalia, fonts, printing)
│   └── supported.nix  # Supported system architectures
│
├── features/          # Feature modules (one file per concern)
│   ├── niri.nix       # Compositor + keybindings
│   ├── noctalia.nix   # Desktop shell
│   ├── editor.nix     # Neovim + config
│   ├── shell.nix      # Bash + config
│   ├── git.nix        # Git + delta
│   ├── terminal.nix   # WezTerm + config
│   ├── scripts.nix    # Utility scripts
│   ├── packages.nix   # CLI tools and desktop apps
│   ├── languages.nix  # Go, Python, Ruby, Node
│   ├── secrets.nix    # sops-nix wiring
│   └── ...            # bat, direnv, foot, ssh, etc.
│
├── hosts/             # Per-machine configuration
│   ├── endor/         # Desktop
│   ├── bespin/        # Laptop
│   ├── macos/         # macOS
│   └── vm/            # QEMU test VM
│
├── users/             # User account definitions
│   └── hao.nix
│
├── home.nix           # Home-manager + user wiring
└── home-modules.nix   # Custom flake-parts option for homeModules
```

Config files stay in their native formats (`.lua`, `.bash`, `.toml`, `.ini`) alongside their `.nix` modules. Nix does minimal wiring — no config is inlined in Nix strings.

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) using age encryption. Encrypted files in `secrets/` are safe to commit — they can only be decrypted with the corresponding age private key.

**Secrets are optional.** The system deploys and runs without them. Features that require secrets (aerc, senpai) are disabled by default and enabled per-host.

| File | Scope |
|------|-------|
| `secrets/common.yaml` | Shared across all hosts |
| `secrets/home.yaml` | User-level (env vars, tokens) |
| `secrets/nixos.yaml` | NixOS-specific |
| `secrets/darwin.yaml` | macOS-specific |

### Setting Up Secrets

#### Step 1: Generate an age key

**Option A — From an SSH key in 1Password:**

Deploy the system first (no secrets needed), then log in and set up 1Password. Once `op` is available:

    mkdir -p ~/.config/sops/age
    op read "op://Private/SSH Key/private key" | ssh-to-age -private-key -o ~/.config/sops/age/keys.txt

Replace `"op://Private/SSH Key/private key"` with your 1Password SSH key reference.

**Option B — From an existing SSH key on disk:**

    mkdir -p ~/.config/sops/age
    ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt

**Option C — Generate a standalone age key:**

    age-keygen -o ~/.config/sops/age/keys.txt

#### Step 2: Register the host

Get the public key:

    age-keygen -y ~/.config/sops/age/keys.txt

Add it to `.sops.yaml` under `keys`, then re-encrypt all secrets files:

    sops updatekeys --yes secrets/*.yaml

#### Step 3: Re-deploy

    sudo nixos-rebuild switch --flake .#endor

Secrets will now be decrypted at activation and placed in `/run/secrets/`.

### Editing Secrets

    sops secrets/home.yaml

## Key Dependencies

| Input | Purpose |
|-------|---------|
| [flake-parts](https://flake.parts/) | Module framework |
| [import-tree](https://github.com/vic/import-tree) | Automatic module discovery |
| [wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) | Portable wrapped packages |
| [home-manager](https://github.com/nix-community/home-manager) | User-level configuration |
| [nix-darwin](https://github.com/LnL7/nix-darwin) | macOS system configuration |
| [sops-nix](https://github.com/Mic92/sops-nix) | Secrets management |

## License

[MIT](LICENSE)
