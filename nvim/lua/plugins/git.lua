return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 500, virt_text_pos = "eol" },
      current_line_blame_formatter = " <author>, <author_time:%R> • <abbrev_sha>",
    },
  },
  {
    "sindrets/diffview.nvim",
    opts = {},
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewFocusFiles", "DiffviewRefresh" },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    },
  },
  {
    "ruifm/gitlinker.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      {
        "<leader>gy",
        function()
          require("gitlinker").get_buf_range_url("n", {
            action_callback = require("gitlinker.actions").copy_to_clipboard,
          })
        end,
        desc = "Copy Git link (line)",
      },
      {
        "<leader>gY",
        function()
          require("gitlinker").get_buf_range_url("v", {
            action_callback = require("gitlinker.actions").copy_to_clipboard,
          })
        end,
        mode = "v",
        desc = "Copy Git link (visual)",
      },
    },
  },
}