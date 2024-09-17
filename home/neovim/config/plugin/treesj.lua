-- https://github.com/Wansmer/treesj

require("treesj").setup({
  use_default_keymaps = false,
})

require("keymaps").map("n", "<leader>j", ":TSJToggle<CR>", { desc = "TreeSJ - Toggle [J]oin/Split" })
