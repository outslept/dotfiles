return {
  { "kevinhwang91/nvim-bqf", ft = "qf", opts = {} },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = { size = 12, open_mapping = [[<c-\>]], direction = "float" },
    keys = { { "<leader>ot", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" } },
  },
}