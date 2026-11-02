local map = vim.keymap.set

map("n", "<A-Left>", "<cmd>vertical resize -3<CR>", { desc = "Resize -width" })
map("n", "<A-Right>", "<cmd>vertical resize +3<CR>", { desc = "Resize +width" })
map("n", "<A-Up>", "<cmd>resize +3<CR>", { desc = "Resize +height" })
map("n", "<A-Down>", "<cmd>resize -3<CR>", { desc = "Resize -height" })

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })

map("n", "<leader>E", function()
  vim.cmd("vsplit | Oil | vertical resize 30")
end, { desc = "Project panel (Oil) right" })

map("t", "<Esc>", [[<C-\><C-n>]], { silent = true })
