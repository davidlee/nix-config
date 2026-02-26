local lz = require("lze")

lz.load({
  -- illuminate
  {
    "vim-illuminate",
    after = function()
      require("illuminate").configure({})
    end,
  },

  -- rainbow-delimiters
  {
    "rainbow-delimiters.nvim",
    after = function()
      require("rainbow-delimiters.setup").setup({
        strategy = {
          [""] = "rainbow-delimiters.strategy.local",
        },
        highlight = {
          "Normal",
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })
    end,
  },
})
