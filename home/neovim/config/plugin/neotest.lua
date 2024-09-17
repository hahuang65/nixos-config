-- https://github.com/nvim-neotest/neotest

local neotest_ns = vim.api.nvim_create_namespace("neotest")
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
      return message
    end,
  },
}, neotest_ns)

require("neotest").setup({
  floating = {
    border = "rounded",
    max_height = 0.75,
    max_width = 0.9,
    options = {},
  },
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
    }),
    require("neotest-go")({
      experimental = {
        test_table = true,
      },
    }),
    require("neotest-rspec"),
  },
})

local map = require("keymaps").map

map("n", "<leader>tp", function()
  require("neotest").run.run({ suite = true })
end, { desc = "[T]est [P]roject" })

map("n", "<leader>ta", function()
  require("neotest").run.attach()
end, { desc = "[T]est - [A]ttach to current run" })

map("n", "<leader>td", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "[T]est - Run test with [d]ebugging" })

map("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "[T]est [F]ile" })

map("n", "<leader>tO", function()
  require("neotest").output_panel.toggle()
end, { desc = "[T]est - Show [o]utput panel" })

map("n", "<leader>to", function()
  require("neotest").output.open({ enter = true })
end, { desc = "[T]est - Show individual [O]utput" })

map("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "[T]est - Open [s]ummary window" })

map("n", "<leader>tS", function()
  require("neotest").run.stop()
end, { desc = "[T]est - [S]top current run" })

map("n", "<leader>tt", function()
  require("neotest").run.run()
end, { desc = "[T]est - Run neares[t]" })

map("n", "<leader>tT", function()
  require("neotest").run.run_last()
end, { desc = "[T]est - re-run las[t]" })

-- `f/F` textobject is taken by `function` in LSP
map("n", "[x", function()
  require("neotest").jump.prev({ status = "failed" })
end, { desc = "Jump to previous failed test" })

map("n", "]x", function()
  require("neotest").jump.next({ status = "failed" })
end, { desc = "Jump to next failed test" })
