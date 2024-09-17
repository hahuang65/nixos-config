-- https://github.com/jmbuhr/otter.nvim

require("otter").setup({
  lsp = {
    hover = {
      border = require("signs").border,
    },
  },
  buffers = {
    set_filetype = true,
  },
  handle_leading_whitespace = true,
})
