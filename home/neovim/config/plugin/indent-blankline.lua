-- https://github.com/lukas-reineke/indent-blankline.nvim

require("ibl").setup({
  scope = {
    enabled = true,
    show_start = true,
  },
  exclude = {
    filetypes = { "help", "lazy", "mason" },
    buftypes = { "terminal" },
  },
})
