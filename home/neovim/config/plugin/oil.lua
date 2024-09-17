-- https://github.com/stevearc/oil.nvim

require("oil").setup({
  columns = { "icon" },
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-x>"] = "actions.select_split",
    ["<C-s>"] = false,
    ["<C-h>"] = false,
  },
})

vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory as buffer" })
