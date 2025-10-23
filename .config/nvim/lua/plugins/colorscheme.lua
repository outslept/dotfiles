return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_foreground = "mix"
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_disable_italic_comment = 0
      vim.g.gruvbox_material_transparent_background = 0
      vim.g.gruvbox_material_better_performance = 1
      vim.o.background = "dark"
    end,
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "gruvbox-material" } },
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },
}