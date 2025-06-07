-- illuminate
-- added via github because the older version in nixpkgs has deprecation warnings
require("mini.deps").add({
  source = "RRethy/vim-illuminate",
})

-- TODO: it'd be great to know how to ensure anything added with mini.deps took
-- precedence over plugins provided by nix. Unfortunately as it stands, we have
-- to remove a plugin from the nix flake in order for require here to load the
-- more up to date version.
--
-- Presumably there's a way to change the load path, or to require with some
-- extra conditions to achieve this.
--
require("mini.deps").later(function()
  require("illuminate").configure({
    --
  })
end)

require("lze").load({
  {

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
          -- blacklist = { 'cpp' }
        })
      end,
    },
  },
})
