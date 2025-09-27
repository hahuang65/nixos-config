{
  config,
  lib,
  osConfig,
  pkgs,
  unstable,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  configDir = "${config.xdg.configHome}/nvim";

  fromCrate =
    {
      pname,
      version,
      hash,
      cargoHash,
    }:
    pkgs.rustPlatform.buildRustPackage {
      inherit pname version;
      src = pkgs.fetchCrate {
        inherit pname version hash;
      };
      cargoHash = cargoHash;
    };

  fromGitHub =
    {
      owner,
      repo,
      rev,
      hash,
      skipModuleTests ? [ ],
    }:
    # TODO: Can we make this less onerous to add/update?
    pkgs.vimUtils.buildVimPlugin {
      name = "${pkgs.lib.strings.sanitizeDerivationName owner}/${pkgs.lib.strings.sanitizeDerivationName repo}";
      src = pkgs.fetchFromGitHub {
        # Use `scripts/github-info` to populate
        owner = owner;
        repo = repo;
        rev = rev;
        hash = hash;
      };
      nvimSkipModules = skipModuleTests;
    };
in
{
  options = {
    neovim = {
      enable = mkEnableOption "neovim";
    };
  };

  config = mkIf config.neovim.enable {
    home.packages = [
      pkgs.autoflake
      pkgs.biome
      pkgs.claude-code
      pkgs.delve
      pkgs.dockerfile-language-server-nodejs
      pkgs.elinks
      pkgs.fish-lsp
      pkgs.gci
      pkgs.gitlint
      pkgs.gofumpt
      pkgs.golangci-lint
      pkgs.gopls
      pkgs.gotools
      pkgs.hadolint
      pkgs.jq
      pkgs.lua5_1
      pkgs.markdownlint-cli
      pkgs.marksman
      pkgs.mypy
      pkgs.nil
      pkgs.nixfmt-rfc-style
      pkgs.packer
      pkgs.postgres-lsp
      pkgs.prettierd
      pkgs.rubocop
      pkgs.ruby-lsp
      pkgs.rubyfmt
      pkgs.ruff
      pkgs.selene
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.sqlfluff
      pkgs.stylua
      pkgs.sqls
      pkgs.taplo
      pkgs.terraform
      pkgs.terraform-ls
      pkgs.tflint
      pkgs.tfsec
      pkgs.typescript
      pkgs.typescript-language-server
      pkgs.vim-language-server
      pkgs.vscode-langservers-extracted
      pkgs.yamlfmt
      pkgs.yamllint
      pkgs.zls

      pkgs.nodePackages.jsonlint
      pkgs.python312Packages.debugpy
      pkgs.rubyPackages.htmlbeautifier

      unstable.bash-language-server
      unstable.fixjson
      unstable.svelte-language-server
      unstable.ty
      unstable.vue-language-server

      (fromCrate {
        pname = "emmylua_ls";
        version = "0.11.0";
        hash = "sha256-BwTf1cCOa66M6To7ynxd0p70xi7YGgu+/bUr68GAFoE=";
        cargoHash = "sha256-btsrvOic17zdOF024MZgfaQ6U98U9M/h8DqiNRLALKQ=";
      })
    ];

    programs.neovim = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/issues/402998
      # TODO: remove workaround on when fixed.
      package = unstable.neovim-unwrapped.overrideAttrs (old: {
        meta = (old.meta or { }) // {
          maintainers = old.maintainers or [ ];
        };
      });

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withPython3 = true;
      withRuby = true;

      extraLuaConfig = ''
        vim.g.mapleader = " "

        -- https://nanotipsforvim.prose.sh/using-pcall-to-make-your-config-more-stable
        local function safeRequire(module)
          local success, loadedModule = pcall(require, module)

          if success then
            return loadedModule
          end

          vim.notify("Error loading " .. module)
        end

        -- Built-ins
        safeRequire("netrw")
        safeRequire("options")

        -- Custom
        safeRequire("statuscolumn")
        safeRequire("terminal")
        safeRequire("keymaps")

        -- Using with nixOS, according to https://nixalted.com/
        require("lazy").setup({
          performance = {
            reset_packpath = false,
            rtp = {
                reset = false,
              }
            },
          dev = {
            path = "${
              pkgs.vimUtils.packDir
                osConfig.home-manager.users.${config.home.username}.programs.neovim.finalPackage.passthru.packpathDirs
            }/pack/myNeovimPackages/start",
            patterns = {""}, -- Specify that all of our plugins will use the dev dir. Empty string is a wildcard.
            fallback = false,
          },
          install = {
            -- Safeguard in case we forget to install a plugin with Nix
            missing = false,
          },
          spec = {
            -- This will load plugins specified in lua/plugins/init.lua
            -- as well as merge in any other lua/plugins/*.lua files
            { import = "plugins" },
          },
        })

        vim.cmd([[ filetype plugin on ]])
      '';

      extraLuaPackages = ps: [ ps.jsregexp ];
      extraPackages = with pkgs; [
        antiprism
        gcc
        luarocks-nix
        tree-sitter
      ];
      extraPython3Packages =
        ps: with ps; [
          cairosvg
          jupyter-client
          pillow
          plotly
          pnglatex
          pyperclip
        ];

      plugins = with unstable.vimPlugins; [
        FixCursorHold-nvim
        blink-cmp
        boole-nvim
        catppuccin-nvim
        claudecode-nvim
        comment-nvim
        conform-nvim
        diagflow-nvim
        direnv-vim
        fidget-nvim
        fold-preview-nvim
        fugitive
        git-conflict-nvim
        gitsigns-nvim
        hover-nvim
        lazydev-nvim
        lazy-nvim
        lualine-nvim
        luasnip
        mini-icons
        molten-nvim
        neotest
        neotest-golang
        neotest-minitest
        neotest-python
        neotest-rspec
        nvim-autopairs
        nvim-bqf
        nvim-dap
        nvim-dap-go
        nvim-dap-python
        nvim-dap-ui
        nvim-dap-virtual-text
        nvim-hlslens
        nvim-lint
        nvim-lspconfig
        nvim-nio
        nvim-pqf
        nvim-treesitter.withAllGrammars
        nvim-treesitter-context
        nvim-treesitter-endwise
        nvim-treesitter-textobjects
        nvim-web-devicons
        oil-nvim
        otter-nvim
        plenary-nvim
        pretty-fold-nvim
        quarto-nvim
        quick-scope
        refactoring-nvim
        render-markdown-nvim
        snacks-nvim
        todo-comments-nvim
        treesj
        vim-cool
        vim-just
        vim-rails
        vim-repeat
        vim-surround

        (fromGitHub {
          owner = "emmanueltouzery";
          repo = "apidocs.nvim";
          rev = "5025cb686c806541705407ac5554d8814e5e5243";
          hash = "sha256-6jHo0KYPIIy7LdHMl16cowT1H3modjxg5caiPISgXHE=";
          skipModuleTests = [ "apidocs.snacks" ]; # For some reason, this fails the test
        })

        (fromGitHub {
          owner = "nvim-zh";
          repo = "colorful-winsep.nvim";
          rev = "1d5d1e33a4e1b8d692a63bf400e837e9b294d239";
          hash = "sha256-KbR2cEeYLkknD/FrKy113yxRaGu3fGGB3G4mnVcxQkE=";
        })

        (fromGitHub {
          owner = "suketa";
          repo = "nvim-dap-ruby";
          rev = "ba36f9905ca9c6d89e5af5467a52fceeb2bbbf6d";
          hash = "sha256-v1DfEnvm43FOEeJDxOzMIc1oIw9wTFQz6odw5zcgIv8=";
        })

        (fromGitHub {
          owner = "kana";
          repo = "vim-fakeclip";
          rev = "59858dabdb55787d7f047c4ab26b45f11ebb533b";
          hash = "sha256-CKQeuUb/MCCDWSKklmpImam8Aek/PvH29XDrw3aILss=";
        })

        (fromGitHub {
          owner = "willothy";
          repo = "wezterm.nvim";
          rev = "032c33b621b96cc7228955b4352b48141c482098";
          hash = "sha256-FeM5cep6bKCfAS/zGAkTls4qODtRhipQojy3OWu1hjY=";
        })

        (fromGitHub {
          owner = "mhanberg";
          repo = "output-panel.nvim";
          rev = "85a205595f1b3904d701ce98aad4df5abbff420b";
          hash = "sha256-Gm03u8PidPQ/cNkl6K5rynZiux12lqgv0E5RXItw8nI=";
        })

        (fromGitHub {
          owner = "rachartier";
          repo = "tiny-devicons-auto-colors.nvim";
          rev = "51f548421f8a74680eff27d283c9d5ea6e8d0074";
          hash = "sha256-Ndkbvxn/x7+fxEYD7JIygqUiItuhoY+4+DaL/pJGKdc=";
        })

        (fromGitHub {
          owner = "yorickpeterse";
          repo = "nvim-window";
          rev = "a8d965f158cff222713a3b3ab341445d331e6e3a";
          hash = "sha256-5tNX7H+qPfyYot+QQb4EcDcrI1oNQx+YnhxmCi2D4n4=";
        })

        (fromGitHub {
          owner = "notjedi";
          repo = "nvim-rooter.lua";
          rev = "7689d05e8ab95acb4b24785253d913c0aae18be9";
          hash = "sha256-3wnT3O9XvFTqClp/uXEyPySsqgWIDWoN0tnvaso8o50=";
        })
      ];
    };

    home.file = {
      "${configDir}" = {
        source = ./config;
        recursive = true;
      };
      ".pylintrc" = {
        source = ./tool_configs/pylintrc;
      };
      ".stylua.toml" = {
        source = ./tool_configs/stylua.toml;
      };
      ".yamlfmt.yml" = {
        source = ./tool_configs/yamlfmt.yml;
      };
    };
  };
}
