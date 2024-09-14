{ config, lib, pkgs, unstable, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    neovim = {
      enable = mkEnableOption "neovim";
    };
  };

  config = mkIf config.neovim.enable {
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

      plugins = with pkgs.vimPlugins; [
        FixCursorHold-nvim
        boole-nvim
        catppuccin-nvim
        cmp-buffer
        cmp-nvim-lsp
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-path
        cmp_luasnip
        comment-nvim
        conform-nvim
        dressing-nvim
        fidget-nvim
        fold-preview-nvim
        fugitive
        git-conflict-nvim
        gitsigns-nvim
        glance-nvim
        gv-vim
        indent-blankline-nvim
        jupytext-nvim
        lsp_lines-nvim
        lsp_signature-nvim
        lspkind-nvim
        lualine-nvim
        luasnip
        molten-nvim
        neotest
        neotest-go
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
        nvim-window-picker
        oil-nvim
        plenary-nvim
        popup-nvim
        pretty-fold-nvim
        project-nvim
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
      ];
    };
  };
}
