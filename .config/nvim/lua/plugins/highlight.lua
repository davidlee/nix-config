local lz = require("lze")

lz.load({
  -- illuminate
  {
    "vim-illuminate",
    after = function() require("illuminate").configure({}) end,
  },

  -- rainbow-delimiters: config via vim.g (not require)
  {
    "rainbow-delimiters.nvim",
    after = function()
      local rd = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rd.strategy.global,
          vim = rd.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
})
