return {
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", event = "VeryLazy", opts = {} },
  { "RRethy/vim-illuminate", event = "VeryLazy" },
  { "chentoast/marks.nvim", event = "VeryLazy", opts = {} },
  { "echasnovski/mini.hipatterns", version = false, event = "VeryLazy", opts = {} },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {},
    keys = { { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
  },
}