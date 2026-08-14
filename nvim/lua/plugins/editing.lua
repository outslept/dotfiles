return {
  {
    "echasnovski/mini.bufremove",
    version = false,
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete buffer" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end,  desc = "Force delete buffer" },
    },
  },
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    opts = { highlight = { on_put = true, on_yank = true } },
    keys = {
      { "]p", "<Plug>(YankyCycleForward)",  desc = "Yank ring forward" },
      { "[p", "<Plug>(YankyCycleBackward)", desc = "Yank ring backward" },
      { "p",  "<Plug>(YankyPutAfter)",      mode = { "n", "x" },        desc = "Put after" },
      { "P",  "<Plug>(YankyPutBefore)",     mode = { "n", "x" },        desc = "Put before" },
      { "gp", "<Plug>(YankyGPutAfter)",     mode = { "n", "x" },        desc = "Put after (keep cursor)" },
      { "gP", "<Plug>(YankyGPutBefore)",    mode = { "n", "x" },        desc = "Put before (keep cursor)" },
    },
  },
  {
    "monaqa/dial.nvim",
    event = "VeryLazy",
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y-%m-%d"],
          augend.semver.alias.semver,
          augend.constant.new({ elements = { "true", "false" } }),
          augend.constant.new({ elements = { "True", "False" }, word = true, cyclic = true }),
        },
      })
    end,
    keys = {
      { "<C-a>",  function() return require("dial.map").inc_normal() end,  expr = true, desc = "Increment" },
      { "<C-x>",  function() return require("dial.map").dec_normal() end,  expr = true, desc = "Decrement" },
      { "g<C-a>", function() return require("dial.map").inc_gnormal() end, expr = true, desc = "Increment g" },
      { "g<C-x>", function() return require("dial.map").dec_gnormal() end, expr = true, desc = "Decrement g" },
      { "<C-a>",  function() return require("dial.map").inc_visual() end,  mode = "v",  expr = true,         desc = "Increment" },
      { "<C-x>",  function() return require("dial.map").dec_visual() end,  mode = "v",  expr = true,         desc = "Decrement" },
    },
  },
  {
    "andrewferrier/debugprint.nvim",
    lazy = false,
    opts = {},
    keys = {
      { "<leader>dp", function() require("debugprint").debugprint() end, desc = "Debug print" },
    },
  },
}
