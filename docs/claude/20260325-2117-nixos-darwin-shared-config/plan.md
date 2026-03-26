# Plan: Cross-Platform NixOS/nix-darwin Configuration

## Goal

Build a single public Nix flake that fully configures a Linux desktop, Linux laptop, and macOS laptop using the dendritic pattern (flake-parts + import-tree). Niri + Noctalia for the Linux desktop, Sway/Waybar as disabled fallback, shared dotfiles via home-manager and wrapper-modules, secrets via sops-nix. A fresh machine is fully set up with one command; a QEMU VM proves it.

## Research Reference

`docs/claude/20260325-2117-nixos-darwin-shared-config/research.md`

---

## Approach

**Build bottom-up, test continuously.** Start with a minimal bootable NixOS VM, then add features one at a time — verifying each with `nix flake check`, `nix run`, or a VM boot. This avoids the "write everything then debug everything" trap.

**Key architectural decisions:**

1. **Dendritic pattern via flake-parts + import-tree** — every `.nix` file is a flake-parts module. No manual import lists. Files organized by feature.
2. **wrapper-modules for portable packages** — Niri, Noctalia, Neovim, Bash, WezTerm wrapped as standalone derivations. Testable via `nix run .#myNvim`.
3. **home-manager for user-level config** — git, ssh, direnv, bat, etc. Loaded as NixOS module on Linux, darwin module on macOS. Same underlying HM modules.
4. **Config in native files** — all application config stays in `.bash`, `.lua`, `.toml`, `.ini` files co-located with their `.nix` module. No inlining in Nix strings.
5. **sops-nix with age keys** — encrypted secrets in the public repo. SSH host key derivation on NixOS, standalone age key on macOS.
6. **Public repo** — the NixOS config repo is public. Every file copied from `~/.dotfiles` must be audited for secrets, employer references, and personal identifiers before committing. Each finding is surfaced to the user for an explicit keep/redact/encrypt decision — nothing is assumed safe.
7. **Config files copied in, not submoduled** — we copy config files from `~/.dotfiles` into this repo (not as submodules, not as flake inputs). This keeps the dendritic pattern's "one file per feature" strength intact. The existing Sourcehut repos remain the historical source but aren't runtime dependencies. We do NOT modify any files in `~/.dotfiles`.

---

## Considerations & Trade-offs

**wrapper-modules vs niri-flake/noctalia-flake modules:** wrapper-modules is less mature but produces portable derivations that fit the dendritic pattern. niri-flake provides battle-tested NixOS/HM modules. We use wrapper-modules (per the vimjoyer video approach) for consistency, but can fall back to niri-flake if wrapper-modules has issues.

**Neovim: symlink + extraPackages vs full Nix plugin management:** Full conversion of 40+ lazy.nvim plugins to Nix is a separate project. We symlink the Lua config and use `programs.neovim.extraPackages` to provide LSP servers/formatters/build tools on PATH, sidestepping NixOS's non-FHS layout issues. Mason is configured to prefer system-provided tools.

**Bash: home-manager programs.bash vs raw symlink:** We use `programs.bash.enable` for the minimal wiring (setting `HISTFILE`, `HISTSIZE`, etc.) and `home.file` to place all `.bash` files. The `initExtra` field contains only a single `source` line pointing to the actual bashrc entrypoint.

**Monorepo vs config-per-host repos:** Single repo. The dendritic pattern's feature-oriented organization prevents the complexity explosion that usually motivates splitting.

**Public repo with interactive security audit:** The repo is public. Every file migrated from `~/.dotfiles` is audited before committing. For each finding (employer reference, personal identifier, network config, credential reference), the user is asked explicitly: keep as-is, redact, parameterize, or sops-encrypt. Nothing is assumed safe — every finding gets a decision. This is more work upfront but results in a repo the user is fully comfortable having public.

**Copying files vs submodules/flake inputs for features:** We copy files from `~/.dotfiles` directly into this repo rather than referencing the existing Sourcehut repos. Submodules or flake inputs per feature would fragment the dendritic pattern — the whole point is that one file owns one feature. The existing repos remain for historical reference but aren't dependencies.

---

## Detailed Changes

### `flake.nix` — Entry Point

The minimal entry point. Declares all inputs and delegates to import-tree.

```nix
{
  description = "Cross-platform NixOS/nix-darwin configuration";

  nixConfig = {
    extra-substituters = [
      "https://niri.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z4ehtRDOKRJDlEK+0="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

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
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
}
```

### `modules/hosts/vm/default.nix` — VM Test Host Definition

The first host is a VM for testing. Real hosts (endor, etc.) come later.

```nix
{ self, inputs, ... }: {
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.vm-configuration
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
    ];
  };
}
```

### `modules/hosts/vm/configuration.nix` — VM Module Composition

```nix
{ self, inputs, ... }: {
  flake.nixosModules.vm-configuration = { pkgs, lib, config, ... }: {
    imports = [
      self.nixosModules.vm-hardware
      self.nixosModules.nixos
      self.nixosModules.user-hao
    ];

    networking.hostName = "vm";
    system.stateVersion = "25.05";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.hao = { ... }: {
        imports = builtins.attrValues self.homeModules;
        home.stateVersion = "25.05";
      };
    };

    virtualisation.vmVariant = {
      virtualisation = {
        memorySize = 4096;
        cores = 4;
        graphics = true;
      };
    };
  };
}
```

### `modules/hosts/vm/hardware.nix` — VM Hardware Placeholder

```nix
{ self, ... }: {
  flake.nixosModules.vm-hardware = { ... }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
  };
}
```

### `modules/os/nixos.nix` — Shared NixOS Settings

```nix
{ self, inputs, ... }: {
  flake.nixosModules.nixos = { pkgs, ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Noctalia prerequisites
    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    # Audio
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # Display
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "niri-session";
        user = "hao";
      };
    };

    # Fonts
    fonts.packages = with pkgs; [
      maple-mono
      noto-fonts-emoji
      nerd-fonts.symbols-only
    ];

    # Core packages
    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      age
      sops
      ssh-to-age
    ];
  };
}
```

### `modules/os/darwin.nix` — Shared Darwin Settings

```nix
{ self, inputs, ... }: {
  flake.darwinModules.darwin = { pkgs, ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    system.defaults = {
      dock.autohide = true;
      finder.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleShowAllExtensions = true;
    };

    fonts.packages = with pkgs; [
      maple-mono
      noto-fonts-emoji
      nerd-fonts.symbols-only
    ];

    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      age
      sops
      ssh-to-age
    ];
  };
}
```

### `modules/os/nix-settings.nix` — Shared Nix Daemon Config

```nix
{ ... }: {
  # This module defines options used by both NixOS and darwin host configs
  # Applied via the host's configuration.nix, not as a direct NixOS/darwin module
}
```

### `modules/features/niri.nix` — Niri Compositor

```nix
{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };

    # Xwayland support
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };

  perSystem = { pkgs, lib, self', ... }: lib.optionalAttrs pkgs.stdenv.isLinux {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        input.keyboard.xkb.layout = "us";
        layout.gaps = 5;
        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.wezterm;
          "Mod+Q".close-window = null;
          "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
        };
      };
    };
  };
}
```

### `modules/features/noctalia.nix` — Noctalia Shell

```nix
{ self, inputs, ... }: {
  perSystem = { pkgs, lib, ... }: lib.optionalAttrs pkgs.stdenv.isLinux {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = {}; # Start with defaults, export later via IPC
    };
  };
}
```

### `modules/features/editor.nix` — Neovim

```nix
{ self, inputs, ... }: {
  flake.homeModules.editor = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        # LSP servers
        lua-language-server
        nil # nix LSP
        gopls
        nodePackages.typescript-language-server
        # Formatters
        stylua
        nixfmt-rfc-style
        gofumpt
        nodePackages.prettier
        # Build tools (for treesitter, plugin builds)
        gcc
        gnumake
        nodejs
      ];
    };

    # Symlink native Lua config
    xdg.configFile."nvim" = {
      source = ./editor;
      recursive = true;
    };
  };
}
```

The `modules/features/editor/` directory contains the full Lua config copied from `~/.dotfiles/nvim/`.

### `modules/features/shell.nix` — Bash

```nix
{ self, inputs, ... }: {
  flake.homeModules.shell = { pkgs, config, ... }: {
    programs.bash = {
      enable = true;
      historyFile = "${config.home.homeDirectory}/.bash_history";
      historyFileSize = 500000;
      historySize = 500000;
      historyControl = [ "erasedups" "ignorespace" ];

      # Minimal wiring — sources the real entrypoint
      initExtra = ''
        source "${config.xdg.configHome}/bash/bashrc"
      '';
    };

    # Place native .bash files
    xdg.configFile."bash" = {
      source = ./shell;
      recursive = true;
    };

    home.packages = with pkgs; [
      fzf
      starship
      ble-sh
    ];
  };
}
```

The `modules/features/shell/` directory contains bashrc, aliases, customizations/, functions/ copied from `~/.dotfiles/bashrc/`.

### `modules/features/git.nix` — Git

```nix
{ self, inputs, ... }: {
  flake.homeModules.git = { pkgs, ... }: {
    programs.git = {
      enable = true;
      userName = "Howard Huang";
      userEmail = "hao@hwrd.me";

      delta = {
        enable = true;
        options = {
          side-by-side = true;
          navigate = true;
        };
      };

      extraConfig = {
        init.defaultBranch = "main";
        core.fsmonitor = true;
        core.untrackedcache = true;
        diff.algorithm = "histogram";
        diff.context = 10;
        push.autoSetupRemote = true;
        pull.rebase = true;
        rebase.autoStash = true;
        merge.conflictstyle = "zdiff3";
      };

      # Include local/secret overrides
      includes = [
        { path = "~/.gitconfig.secret"; }
      ];
    };

    # Place native git config extras (aliases, URL shortcuts)
    xdg.configFile."git/config.extra" = {
      source = ./git/config.extra;
    };
  };
}
```

The `modules/features/git/` directory contains sanitized git config files (employer refs moved to `~/.gitconfig.secret` which is sops-managed).

### `modules/features/scripts.nix` — Utility Scripts

```nix
{ self, inputs, ... }: {
  flake.homeModules.scripts = { pkgs, lib, config, ... }: {
    home.sessionPath = [
      "${config.xdg.configHome}/scripts/shared"
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      "${config.xdg.configHome}/scripts/linux"
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      "${config.xdg.configHome}/scripts/darwin"
    ];

    xdg.configFile."scripts" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
```

### `modules/features/secrets.nix` — sops-nix Wiring

```nix
{ self, inputs, ... }: {
  # System-level sops for NixOS
  flake.nixosModules.secrets = { config, ... }: {
    sops = {
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age.keyFile = "/var/lib/sops-nix/key.txt";
      age.generateKey = true;
    };
  };

  # System-level sops for darwin
  flake.darwinModules.secrets = { config, ... }: {
    sops = {
      defaultSopsFormat = "yaml";
      age.keyFile = "/Users/hao/.config/sops/age/keys.txt";
    };
  };

  # User-level secrets via home-manager
  flake.homeModules.secrets = { config, ... }: {
    sops = {
      defaultSopsFile = ../../secrets/home.yaml;
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  };
}
```

### `modules/features/sway.nix` — Legacy Fallback (Disabled)

```nix
{ self, inputs, ... }: {
  flake.nixosModules.sway = { pkgs, ... }: {
    programs.sway = {
      enable = true;
      # Not the default session — greetd points to niri
    };

    environment.systemPackages = with pkgs; [
      waybar
      fuzzel
      mako
    ];
  };
}
```

### `modules/users/hao.nix` — User Account

```nix
{ self, inputs, ... }: {
  flake.nixosModules.user-hao = { pkgs, ... }: {
    users.users.hao = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      shell = pkgs.bash;
    };
  };

  flake.darwinModules.user-hao = { pkgs, ... }: {
    users.users.[MACOS_USER] = {
      shell = pkgs.bash;
      home = "/Users/[MACOS_USER]";
    };
  };
}
```

### `modules/hosts/macos/default.nix` — Darwin Host

```nix
{ self, inputs, ... }: {
  flake.darwinConfigurations.macos = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      self.darwinModules.darwin
      self.darwinModules.user-hao
      self.darwinModules.secrets
      inputs.sops-nix.darwinModules.sops
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.hao = { ... }: {
            imports = builtins.attrValues self.homeModules;
            home.stateVersion = "25.05";
          };
        };
      }
    ];
  };
}
```

---

## New Files Summary

| Path | Purpose |
|------|---------|
| `flake.nix` | Entry point with all inputs |
| `.sops.yaml` | age key mapping for secrets |
| `.gitignore` | Ignore `.builds/`, `result`, `nixos.qcow2`, `_local/` |
| `secrets/common.yaml` | Shared encrypted secrets |
| `secrets/home.yaml` | User-level encrypted secrets (env vars, tokens) |
| `secrets/nixos.yaml` | NixOS-specific encrypted secrets |
| `secrets/darwin.yaml` | darwin-specific encrypted secrets |
| `modules/hosts/vm/{default,configuration,hardware}.nix` | Desktop host |
| `modules/hosts/bespin/{default,configuration,hardware}.nix` | Laptop host |
| `modules/hosts/macos/{default,configuration}.nix` | macOS host |
| `modules/os/{nixos,darwin,nix-settings}.nix` | Shared OS-level config |
| `modules/features/niri.nix` | Niri compositor + wrapper |
| `modules/features/noctalia.nix` | Noctalia shell + wrapper |
| `modules/features/editor.nix` + `editor/` | Neovim + native Lua config |
| `modules/features/shell.nix` + `shell/` | Bash + native .bash files |
| `modules/features/git.nix` + `git/` | Git config |
| `modules/features/terminal.nix` + `terminal/` | WezTerm + native Lua config |
| `modules/features/scripts.nix` + `scripts/` | Utility scripts |
| `modules/features/secrets.nix` | sops-nix wiring |
| `modules/features/sway.nix` | Sway/Waybar fallback (disabled) |
| `modules/features/{bat,direnv,foot,inputrc,mise,ssh,fonts}.nix` | Small tool configs |
| `modules/features/aerospace.nix` | macOS tiling WM |
| `modules/users/hao.nix` | User account |

---

## Dependencies

| Input | URL | Purpose |
|-------|-----|---------|
| nixpkgs | `github:nixos/nixpkgs/nixos-unstable` | Package set |
| flake-parts | `github:hercules-ci/flake-parts` | Module framework |
| import-tree | `github:vic/import-tree` | Auto module discovery |
| wrapper-modules | `github:BirdeeHub/nix-wrapper-modules` | Portable wrapped packages |
| home-manager | `github:nix-community/home-manager` | User-level config |
| nix-darwin | `github:LnL7/nix-darwin` | macOS system config |
| sops-nix | `github:Mic92/sops-nix` | Secrets management |

---

## Testing Strategy

Testing follows the iteration workflow from research: `nix flake check` → `nix build` → `nix run` → VM boot.

**Flake validation:** After each phase, `nix flake check` must pass. This catches evaluation errors, type mismatches, and missing attributes.

**Individual package tests:** After creating each wrapper-modules package, verify with `nix run .#packageName` that the wrapped application launches correctly with its config.

**VM boot test:** After Phase 3 (core features), build and boot the VM to verify the full system comes up with greetd → niri → noctalia.

**Secrets test:** After Phase 5, verify that `sops secrets/home.yaml` can edit secrets, and that a VM boot correctly decrypts and places secrets in `/run/secrets/`.

| Test | Phase | Command | Validates |
|------|-------|---------|-----------|
| Flake evaluates | 1 | `nix flake check` | No syntax/evaluation errors |
| System builds | 1 | `nix build .#nixosConfigurations.vm.config.system.build.toplevel` | Full closure builds |
| VM boots to greetd | 2 | `nixos-rebuild build-vm --flake .#vm` | Boot, services, display manager |
| `nix run .#myNiri` | 3 | Launch niri standalone | Wrapper produces working compositor |
| `nix run .#myNoctalia` | 3 | Launch noctalia standalone | Wrapper produces working shell |
| `nix run .#myNvim` on a file | 4 | Open a file, verify LSP | Neovim config + extraPackages work |
| `nix run .#myBash` | 4 | Launch bash, check aliases | Bash config sources correctly |
| VM boots with full desktop | 4 | Boot VM, log in | Niri + Noctalia + all user config |
| Secrets decrypt | 5 | Boot VM, check `/run/secrets/` | sops-nix activation works |
| Env vars sourced | 5 | In VM bash, `echo $GITHUB_TOKEN` | Bash sources decrypted env file |
| Darwin builds | 7 | `nix build .#darwinConfigurations.macos.system` | darwin config evaluates and builds |

---

## Todo List

### Phase 0: Security & Privacy Audit (Interactive)

The repo is public. Every finding from the security audit is presented to the user for an explicit decision before any file is committed. Nothing is assumed safe.

- [x] **Present each finding to the user for a decision.** Decisions recorded below.
- [x] Employer references: `git/config` employer refs (`[EMPLOYER]`, `[EMPLOYER_PROJECT]`) → **move to `~/.gitconfig.secret`**. `git/[EMPLOYER_PROJECT].config` → **move to `~/.gitconfig.secret`** (not excluded). `bashrc/customizations/darwin.bash` (`$HOME/Projects/[EMPLOYER_PROJECT]/toolbox`) → **keep as-is**.
- [x] Personal identifiers: emails, GitHub handle, Sourcehut handle, full name, branch prefix → **keep all**. macOS username `[MACOS_USER]` in `zsh/zshrc` → **redact, use `$HOME`**. `sketchybar/install.sh` plist identifier → **genericize to use current user**.
- [x] Network config: `scripts/hosts/[REMOVED_HOST]/synergy` → **remove entirely** (no longer used). `scripts/linux/romm` → **sops-encrypt**.
- [x] Credential references: `aerc/accounts.conf` → **sops-encrypt**. `senpai/senpai.scfg` → **sops-encrypt**.
- [x] Sourcehut CI artifacts: `.builds/mirror.yml` files → **keep** (refs, not secrets).
- [x] Hardcoded usernames in scripts: `srht-repo-new`, `conform.lua`, `git/config` pushInsteadOf → **keep all** (handles are public).
- [x] Runtime secrets: `~/.secrets.sh` → **always sops-nix**.

### Phase 1: Foundation — Bootable Skeleton

The first host is `vm` (a QEMU test host). The real desktop host `endor` comes in Phase 7 and is near-identical to `vm` but with real hardware config.

- [x] Initialize git repo in `/home/hao/Documents/Projects/nixos/`
- [x] Create `flake.nix` with all inputs
- [x] Create `.gitignore` (`result`, `*.qcow2`, `_local/`)
- [x] Create `modules/os/nixos.nix` — shared NixOS settings (nix daemon, networking, audio, display, fonts)
- [x] Create `modules/os/nix-settings.nix` — shared nix daemon config
- [x] Create `modules/users/hao.nix` — user account definition (NixOS: `hao`, darwin: `[MACOS_USER]`)
- [x] Create `modules/hosts/vm/default.nix` — nixosConfigurations.vm
- [x] Create `modules/hosts/vm/configuration.nix` — module composition + VM variant
- [x] Create `modules/hosts/vm/hardware.nix` — placeholder hardware config
- [x] Verify: `nix flake check` passes
- [x] Verify: `nix build .#nixosConfigurations.vm.config.system.build.toplevel` succeeds

### Phase 2: Desktop Environment — Niri + Noctalia

- [x] Create `modules/features/niri.nix` — wrapper-modules niri package + NixOS module
- [x] Create `modules/features/noctalia.nix` — wrapper-modules noctalia package
- [ ] Verify: `nix run .#niri` launches the compositor
- [ ] Verify: `nix run .#noctalia` launches the shell
- [ ] Verify: VM boots to greetd → niri session with noctalia bar

### Phase 3: Legacy Fallback — Sway + Waybar (Disabled)

- [x] Create `modules/features/sway.nix` — sway available but not default session
- [x] Copy sway config from `~/.dotfiles/sway/` to `modules/features/sway/`
- [x] Copy waybar config from `~/.dotfiles/waybar/` to `modules/features/waybar/`
- [x] Verify: `nix flake check` passes (sway module not imported by vm host, so greetd defaults to niri)

### Phase 4: Core Shared Features — Editor, Shell, Git, Scripts

- [x] Create `modules/home-modules.nix` — custom mergeable `flake.homeModules` option (flake-parts plumbing)
- [x] Copy nvim config from `~/.dotfiles/nvim/` to `modules/features/editor/`
- [x] Create `modules/features/editor.nix` — neovim + extraPackages + xdg.configFile symlink
- [ ] Verify: `nix run .#nvim` — opens, LSP attaches, treesitter highlights (manual test)
- [x] Copy bashrc from `~/.dotfiles/bashrc/` to `modules/features/shell/`
- [x] Create `modules/features/shell.nix` — programs.bash + xdg.configFile
- [ ] Verify: bash config sources correctly (manual test)
- [x] Copy git config from `~/.dotfiles/git/` to `modules/features/git/` (employer refs moved to `~/.gitconfig.secret`, `[EMPLOYER_PROJECT].config` removed)
- [x] Create `modules/features/git.nix` — programs.git + delta + xdg.configFile
- [x] Copy scripts from `~/.dotfiles/scripts/` to `modules/features/scripts/` (excluded `hosts/[REMOVED_HOST]`)
- [x] Create `modules/features/scripts.nix` — sessionPath + xdg.configFile
- [x] Copy wezterm config from `~/.dotfiles/wezterm/` to `modules/features/terminal/`
- [x] Create `modules/features/terminal.nix` — wezterm package + xdg.configFile
- [x] Verify: `nix flake check` passes with all home modules
- [ ] Verify: VM boots with full user environment (manual test)

### Phase 5: Secrets Management

- [x] Generate personal age key: `age-keygen -o ~/.config/sops/age/keys.txt`
- [x] Create `.sops.yaml` with personal key + placeholder host keys
- [x] Create `modules/features/secrets.nix` — sops-nix wiring for NixOS, darwin, and home-manager
- [x] Create `modules/home.nix` — shared home-manager + user wiring (imports user-hao + sops HM module)
- [x] Create `secrets/home.yaml` — encrypted env vars
- [x] Create `secrets/common.yaml` — shared secrets
- [x] Create `secrets/nixos.yaml` — NixOS-specific secrets
- [x] Create `secrets/darwin.yaml` — darwin-specific secrets
- [x] sops-encrypt `aerc/accounts.conf` → `aerc/account/config` in common.yaml, `modules/features/aerc.nix` writes to xdg path
- [x] sops-encrypt `senpai/senpai.scfg` → `senpai/config` in common.yaml, `modules/features/senpai.nix` writes to xdg path
- [x] Parameterize romm script — reads `ROMM_SSH_HOST`, `ROMM_PORT`, `ROMM_SSH_PORT`, `ROMM_SFTP_PORT` from env with fallback defaults. Secrets stored as nested `romm/ssh/host`, `romm/ssh/port`, `romm/sftp/port`, `romm/port` in common.yaml
- [x] Update `modules/features/shell/bashrc` to source `/run/secrets-rendered/env_secrets` with fallback to `~/.secrets.sh`
- [ ] Verify: VM boots, secrets appear in `/run/secrets/`, bash env vars are set (manual test)

### Phase 6: Small Tool Configs

- [x] Create `modules/features/bat.nix` — programs.bat + xdg.configFile
- [x] Create `modules/features/direnv.nix` — programs.direnv + nix-direnv
- [x] Create `modules/features/foot.nix` — foot terminal + xdg.configFile
- [x] Create `modules/features/inputrc.nix` — readline config via xdg.configFile
- [x] Create `modules/features/mise.nix` — mise package + xdg.configFile
- [x] Create `modules/features/ssh.nix` — programs.ssh
- [x] Create `modules/features/fonts.nix` — fonts.packages (NixOS + darwin, maple-mono.NF)
- [x] Verify: `nix flake check` passes

### Phase 7: Real Linux Hosts — Desktop (endor) + Laptop

`endor` is near-identical to `vm` but with real hardware config. The laptop host follows the same pattern with power management additions.

- [x] Create `modules/hosts/endor/default.nix` — nixosConfigurations.endor
- [x] Create `modules/hosts/endor/configuration.nix` — near-identical to vm, real hardware
- [x] Create `modules/hosts/endor/hardware.nix` — placeholder (replace with real hardware-configuration)
- [x] Create `modules/hosts/bespin/default.nix`
- [x] Create `modules/hosts/bespin/configuration.nix` — reuses same feature modules + tlp power management
- [x] Create `modules/hosts/bespin/hardware.nix` — placeholder
- [x] Verify: `nix flake check` passes for all NixOS hosts

### Phase 8: macOS Host — nix-darwin

- [x] Create `modules/systems/darwin.nix` — shared darwin settings (system.defaults, fonts)
- [x] Create `modules/hosts/macos/default.nix` — darwinConfigurations.macos
- [x] Create `modules/features/aerospace.nix` — macOS tiling WM config (from ~/.dotfiles/aerospace/)
- [x] Create `modules/home-modules.nix` — custom mergeable `darwinModules` option (same pattern as homeModules)
- [x] Verify: `nix flake check` passes including darwinConfigurations

### Phase 9: Final Validation

- [ ] Full VM boot test: vm boots, greetd → niri → noctalia, all tools work
- [ ] endor builds: `nix build .#nixosConfigurations.endor.config.system.build.toplevel`
- [ ] bespin builds with power management
- [ ] darwin build succeeds (full build, not just evaluation)
- [ ] All `nix run` packages work: myNiri, myNoctalia, myNvim, myBash, myWezterm
- [ ] Secrets decrypt correctly in VM
- [ ] No hardcoded secrets or employer references in repo (grep audit)
- [ ] `nix flake check` clean

### Phase 10: Documentation Redaction

Redact sensitive information from `plan.md`, `plan.html`, and `research.md` before committing to the public repo. Employer names, specific IPs, and credential references should be replaced with redacted placeholders (e.g., `[EMPLOYER]`, `[HOME_IP]`) so the decisions around them remain obvious to a reader.

- [x] Redact employer names from plan.md/research.md — replaced with `[EMPLOYER]` / `[EMPLOYER_PROJECT]`
- [x] Redact specific IPs and ports from research.md
- [x] Redact email provider name and 1Password item names from research.md
- [x] Redact macOS username — replaced with `[MACOS_USER]`
- [x] Update plan.html to match redacted plan.md
- [x] Update research.html to match redacted research.md
- [x] Verify: grep audit confirms no sensitive content remains in docs/claude/ files
