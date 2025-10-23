return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
      { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
      { "<leader>h1", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
      { "<leader>h2", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
      { "<leader>h3", function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
      { "<leader>h4", function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
    },
  },
  {
    "stevearc/oil.nvim",
    event = "VeryLazy",
    opts = { default_file_explorer = true, view_options = { show_hidden = true } },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer" },
    },
  },
  {
    "stevearc/aerial.nvim",
    event = "LspAttach",
    opts = { attach_mode = "global", backends = { "lsp", "treesitter", "markdown" } },
    keys = {
      { "<leader>co", "<cmd>AerialToggle!<cr>", desc = "Symbols outline" },
    },
  },
}