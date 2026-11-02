return {
  {
    "chaosteil/pierre-theme.nvim",
    lazy = false,
    priority = 1000,
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "pierre-dark" } },
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "pierre" } } },
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },

  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = { default_file_explorer = true, view_options = { show_hidden = true } },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = false,
      current_line_blame_opts = { delay = 500 },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = {},
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    },
  },

  { "rmagatti/goto-preview", event = "LspAttach", opts = { default_mappings = true } },
  {
    "andrewferrier/debugprint.nvim",
    opts = {},
    keys = {
      { "<leader>dp", function() require("debugprint").debugprint() end, desc = "Debug print" },
    },
  },
  { "kevinhwang91/nvim-bqf", ft = "qf", opts = {} },
  { "chentoast/marks.nvim", event = "VeryLazy", opts = {} },
  { "HiPhish/rainbow-delimiters.nvim", event = "VeryLazy" },
}
