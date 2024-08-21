{ lib, pkgs, ... }:

let
  fromGithub = import ./fromGithub.nix;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      (nvim-treesitter.withPlugins (grammars: with grammars; [
        bash
	css
	csv
	dockerfile
	git_config
	git_rebase
	gitcommit
	gitignore
	go
	gomod
	gosum
	hcl
	html
	jq
	json
	lua
	make
	markdown
	nix
	python
	query
	ruby
	sql
	ssh_config
	terraform
	toml
	udev
	vim
	vimdoc
	vue
	xml
	yaml
      ]))
      (fromGithub { user = "nvim-telescope"; repo = "telescope.nvim"; })
    ];
  };
}
