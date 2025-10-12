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
      repo,
      rev,
      hash,
      skipModuleTests ? [ ],
    }:
    let
      repoParts = lib.splitString "/" repo;
      owner = lib.elemAt repoParts 0;
      repoName = lib.elemAt repoParts 1;
    in
    pkgs.vimUtils.buildVimPlugin {
      name = "${pkgs.lib.strings.sanitizeDerivationName owner}/${pkgs.lib.strings.sanitizeDerivationName repoName}";
      src = pkgs.fetchFromGitHub {
        # Use `scripts/github-info` to populate
        inherit
          rev
          hash
          ;
        owner = owner;
        repo = repoName;
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
      pkgs.amp-cli
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
          repo = "sourcegraph/amp.nvim";
          rev = "ccce82a82897b788d748e59cf09d958c3bfdd7e6";
          hash = "17d1w93ihxpz8m06z7ab47s57669pq2qpj6ah7sdv9nik00incps";
        })

        (fromGitHub {
          repo = "emmanueltouzery/apidocs.nvim";
          rev = "6f34023f9a14dda5fa1f06d8ffe53e689324d2d2";
          hash = "0nhnsa7iz5kfdb9592vdf5g65zac6b6q012zkknr285vy3dxfsnv";
          skipModuleTests = [ "apidocs.snacks" ]; # For some reason, this fails the test
        })

        (fromGitHub {
          repo = "nvim-zh/colorful-winsep.nvim";
          rev = "e555611c8f39918e30d033a97ea1a5af457ce75e";
          hash = "0f5nzwzh5svy868by19r7yg67g87npdclcza74r6fj3a94r3zm04";
        })

        (fromGitHub {
          repo = "suketa/nvim-dap-ruby";
          rev = "ba36f9905ca9c6d89e5af5467a52fceeb2bbbf6d";
          hash = "sha256-v1DfEnvm43FOEeJDxOzMIc1oIw9wTFQz6odw5zcgIv8=";
        })

        (fromGitHub {
          repo = "kana/vim-fakeclip";
          rev = "59858dabdb55787d7f047c4ab26b45f11ebb533b";
          hash = "sha256-CKQeuUb/MCCDWSKklmpImam8Aek/PvH29XDrw3aILss=";
        })

        (fromGitHub {
          repo = "willothy/wezterm.nvim";
          rev = "032c33b621b96cc7228955b4352b48141c482098";
          hash = "sha256-FeM5cep6bKCfAS/zGAkTls4qODtRhipQojy3OWu1hjY=";
        })

        (fromGitHub {
          repo = "mhanberg/output-panel.nvim";
          rev = "634f735d6a2a9a63b5849ab61f944f7a1a8b3780";
          hash = "0p6qr4by2fhhsnqv39v4msnwbmj7jfi35gklf7a69mq9x84wrr1z";
        })

        (fromGitHub {
          repo = "rachartier/tiny-devicons-auto-colors.nvim";
          rev = "51f548421f8a74680eff27d283c9d5ea6e8d0074";
          hash = "sha256-Ndkbvxn/x7+fxEYD7JIygqUiItuhoY+4+DaL/pJGKdc=";
        })

        (fromGitHub {
          repo = "yorickpeterse/nvim-window";
          rev = "a8d965f158cff222713a3b3ab341445d331e6e3a";
          hash = "sha256-5tNX7H+qPfyYot+QQb4EcDcrI1oNQx+YnhxmCi2D4n4=";
        })

        (fromGitHub {
          repo = "notjedi/nvim-rooter.lua";
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
