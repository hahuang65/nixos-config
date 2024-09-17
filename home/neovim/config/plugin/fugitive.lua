-- https://github.com/tpope/vim-fugitive

local map = require("keymaps").map

map("n", "<leader>gb", require("git").change_branch, { desc = "[G]it [b]ranch" })
map("n", "<leader>gB", ":Git repo view --web<CR>", { desc = "[G]it - Open in [b]rowser" })
map("n", "<leader>gc", ":GV!<CR>", { desc = "[G]it [c]ommits (Buffer)" })
map("n", "<leader>gC", ":GV<CR>", { desc = "[G]it [C]ommits (Project)" })
map("n", "<leader>gg", require("git").toggle_fugitive, { desc = "Toggle Fugitive" })
map("n", "<leader>gl", ":Git log<CR>", { desc = "[G]it [L]og" })
map("n", "<leader>gN", require("git").new_branch, { desc = "[G]it [N]ew Branch" })
map("n", "<leader>gO", ":Git pr view --web<CR>", { desc = "[G]it - [O]pen PR in browser" })
map("n", "<leader>gp", ":Git publish<CR>", { desc = "[G]it [P]ublish" })
map("n", "<leader>gP", ":Git pr list --web<CR>", { desc = "[G]it - List open [P]Rs in browser" })
map("n", "<leader>gR", ":Git pr create --web --fill-first<CR>", { desc = "[G]it - Create pull [r]equest" })
map("n", "<leader>gt", ":Git trunk<CR>", { desc = "[G]it - Switch to [t]runk branch" })
map("n", "<leader>gT", ":Git retrunk<CR>", { desc = "[G]it - Rebase Against [t]runk branch" })
map("n", "<leader>gs", ":Git sync<CR>", { desc = "[G]it Sync" })
map("n", "<leader>gS", ":Git shove<CR>", { desc = "[G]it Shove" })
map("n", "<leader>g[", ":diffget //2 | :diffupdate<CR>", { desc = "Conflict Select (Left)" })
map("n", "<leader>g]", ":diffget //3 | :diffupdate<CR>", { desc = "Conflict Select (Right)" })
map({ "n", "v" }, "<leader>g?", require("git").commits_for_lines, { desc = "Show commits for current line" })
