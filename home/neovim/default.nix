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
  fromGitHub =
    {
      owner,
      repo,
      rev,
      hash,
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
      pkgs.delve
      pkgs.dockerfile-language-server-nodejs
      pkgs.gci
      pkgs.gitlint
      pkgs.gofumpt
      pkgs.golangci-lint
      pkgs.gopls
      pkgs.gotools
      pkgs.hadolint
      pkgs.jq
      pkgs.lua5_1
      pkgs.lua-language-server
      pkgs.markdownlint-cli
      pkgs.marksman
      pkgs.mypy
      pkgs.nil
      pkgs.nixfmt-rfc-style
      pkgs.packer
      pkgs.prettierd
      pkgs.rubocop
      pkgs.ruby-lsp
      pkgs.rubyfmt
      pkgs.ruff
      pkgs.selene
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.solargraph
      pkgs.sqlfluff
      pkgs.stylua
      pkgs.sqls
      pkgs.taplo
      pkgs.terraform
      pkgs.terraform-ls
      pkgs.tflint
      pkgs.typescript
      pkgs.vim-language-server
      pkgs.yamlfmt
      pkgs.yamllint

      pkgs.nodePackages.jsonlint
      pkgs.python312Packages.debugpy
      pkgs.python312Packages.jupytext
      pkgs.rubyPackages.htmlbeautifier

      unstable.basedpyright
      unstable.bash-language-server
      unstable.fixjson
      unstable.svelte-language-server
      unstable.vue-language-server
    ];

    programs.neovim = {
      enable = true;
      package = unstable.neovim-unwrapped;

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
        pkgs.antiprism
        pkgs.gcc
        pkgs.luarocks-nix
        pkgs.tree-sitter

        nodePackages.neovim
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
        boole-nvim
        catppuccin-nvim
        cmp-buffer
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-path
        cmp_luasnip
        comment-nvim
        conform-nvim
        direnv-vim
        dressing-nvim
        fidget-nvim
        fold-preview-nvim
        fugitive
        git-conflict-nvim
        gitsigns-nvim
        gv-vim
        indent-blankline-nvim
        jupytext-nvim
        lazy-nvim
        lsp_lines-nvim
        lsp_signature-nvim
        lspkind-nvim
        lualine-nvim
        luasnip
        molten-nvim
        neotest
        neotest-golang
        neotest-python
        neotest-rspec
        nvim-autopairs
        nvim-cmp
        nvim-dap
        nvim-dap-go
        nvim-dap-python
        nvim-dap-ui
        nvim-dap-virtual-text
        nvim-hlslens
        nvim-lint
        nvim-lspconfig
        nvim-nio
        nvim-notify
        nvim-pqf
        nvim-treesitter.withAllGrammars
        nvim-treesitter-context
        nvim-treesitter-endwise
        nvim-treesitter-textobjects
        nvim-web-devicons
        oil-nvim
        otter-nvim
        plenary-nvim
        popup-nvim
        pretty-fold-nvim
        quarto-nvim
        quick-scope
        refactoring-nvim
        telescope-fzf-native-nvim
        telescope-nvim
        todo-comments-nvim
        treesj
        vim-cool
        vim-just
        vim-rails
        vim-repeat
        vim-surround

        (fromGitHub {
          owner = "nvim-zh";
          repo = "colorful-winsep.nvim";
          rev = "210f6532772d7d2fefdf1f39081b965be4a3b2ef";
          hash = "sha256-KbR2cEeYLkknD/FrKy113yxRaGu3fGGB3G4mnVcxQkE=";
        })

        (fromGitHub {
          owner = "suketa";
          repo = "nvim-dap-ruby";
          rev = "4176405d186a93ebec38a6344df124b1689cfcfd";
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
          rev = "f73bba23ab4becd146fa2d0a3a16a84b987eeaca";
          hash = "sha256-FeM5cep6bKCfAS/zGAkTls4qODtRhipQojy3OWu1hjY=";
        })

        (fromGitHub {
          owner = "mhanberg";
          repo = "output-panel.nvim";
          rev = "65bb44a5d5dbd40f3793a8c591b65a0c5f260bd9";
          hash = "sha256-Gm03u8PidPQ/cNkl6K5rynZiux12lqgv0E5RXItw8nI=";
        })

        (fromGitHub {
          owner = "rachartier";
          repo = "tiny-devicons-auto-colors.nvim";
          rev = "a39fa4c92268832f6034306793b8acbfec2a7549";
          hash = "sha256-Ndkbvxn/x7+fxEYD7JIygqUiItuhoY+4+DaL/pJGKdc=";
        })

        (fromGitHub {
          owner = "yorickpeterse";
          repo = "nvim-window";
          rev = "81f29840ac3aaeea6fc2153edfabebd00d692476";
          hash = "sha256-5tNX7H+qPfyYot+QQb4EcDcrI1oNQx+YnhxmCi2D4n4=";
        })

        (fromGitHub {
          owner = "notjedi";
          repo = "nvim-rooter.lua";
          rev = "36c597962c5f136d6230f53837ff14fcaf81eff7";
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
