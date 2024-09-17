-- https://github.com/anuvyklack/fold-preview.nvim

local map = require("keymaps").map

require("fold-preview").setup({
  auto = false,
  default_keybindings = false,
  border = require("signs").border,
})

map("n", "Z", function()
  require("fold-preview").toggle_preview()
end, { desc = "Preview fold" })
