-- https://gitlab.com/yorickpeterse/nvim-window.git

require("keymaps").map({ "i", "n", "t", "v" }, "<M-w>", function()
  require("nvim-window").pick()
end, { desc = "[W]indow picker" })
