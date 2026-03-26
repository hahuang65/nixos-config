{ self, inputs, ... }: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      maple-mono.NF
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
    ];
  };

  flake.darwinModules.fonts = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      maple-mono.NF
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
    ];
  };
}
