-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
local opts = { silent = true }

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })

map("n", "<A-Left>", "<cmd>vertical resize -3<CR>", { desc = "Resize -width" })
map("n", "<A-Right>", "<cmd>vertical resize +3<CR>", { desc = "Resize +width" })
map("n", "<A-Up>", "<cmd>resize +3<CR>", { desc = "Resize +height" })
map("n", "<A-Down>", "<cmd>resize -3<CR>", { desc = "Resize -height" })

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Alternate buffer" })

map("n", "<leader>E", function()
  vim.cmd("vsplit")
  vim.cmd("Oil")
  vim.cmd("vertical resize 30")
end, { desc = "Project panel (Oil) right" })

map("t", "<Esc>", [[<C-\><C-n>]], opts)
