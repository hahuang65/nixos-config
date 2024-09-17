-- https://github.com/windwp/nvim-autopairs

require("nvim-autopairs").setup({
  check_ts = true, -- Treesitter integration
})

-- Auto-align pairs after completion
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
