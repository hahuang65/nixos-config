-- https://github.com/quarto-dev/quarto-nvim
--
require("quarto").setup({
  lspFeatures = {
    languages = { "python", "bash", "lua", "html", "go", "ruby" },
    chunks = "all",
    diagnostics = {
      enabled = true,
      triggers = { "BufWritePost" },
    },
    completion = {
      enabled = true,
    },
  },
  keymap = {
    hover = "K",
    definition = "gd",
    rename = "<leader>rn",
    references = "gr",
    format = "<leader>gf",
  },
  codeRunner = {
    enabled = true,
    default_method = "molten",
  },
})

local runner = require("quarto.runner")
vim.keymap.set("n", "<leader>nn", runner.run_cell, { desc = "Notebook - Run cell", silent = true })
vim.keymap.set("n", "<leader>na", runner.run_above, { desc = "Notebook - Run above", silent = true })
vim.keymap.set("n", "<leader>nA", runner.run_all, { desc = "Notebook - Run all", silent = true })
