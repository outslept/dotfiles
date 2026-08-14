-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 }) end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local line = vim.api.nvim_buf_get_mark(0, '"')[1]
    if line > 1 and line <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
    end
  end,
})