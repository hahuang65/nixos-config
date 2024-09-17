-- https://github.com/rachartier/tiny-devicons-auto-colors.nvim

local theme_colors = require("catppuccin.palettes").get_palette(require("common").catppuccin_palette)
require("tiny-devicons-auto-colors").setup({
  colors = theme_colors,
})
