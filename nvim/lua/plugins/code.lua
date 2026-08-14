return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = { max_lines = 3, multiline_threshold = 1 },
  },
  {
    "rmagatti/goto-preview",
    event = "LspAttach",
    opts = { default_mappings = true },
  },
}