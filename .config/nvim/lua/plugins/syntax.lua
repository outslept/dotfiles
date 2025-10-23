return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "markdown", "markdown_inline",
        "regex", "bash", "json", "yaml", "toml",
        "html", "css", "javascript", "typescript", "tsx",
      },
      auto_install = true,
    },
  },
}