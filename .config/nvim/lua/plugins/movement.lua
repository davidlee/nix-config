require("lze").load({
  --
  -- leap
  --
  {
    "leap.nvim",
    after = function()
      require("leap").set_default_mappings()
      -- Exclude whitespace and the middle of alphabetic words from preview:
      --   foobar[baaz] = quux
      --   ^----^^^--^^-^-^--^
      require("leap").opts.preview_filter = function(ch0, ch1, ch2)
        return not (ch1:match("%s") or ch0:match("%a") and ch1:match("%a") and ch2:match("%a"))
      end
    end,
  },

  -- flit
  {
    "flit.nvim",
    after = function()
      require("flit").setup({
        keys = { f = "f", F = "F", t = "t", T = "T" },
        -- A string like "nv", "nvo", "o", etc.
        labeled_modes = "v",
        -- Repeat with the trigger key itself.
        clever_repeat = true,
        multiline = true,
        -- Like `leap`s similar argument (call-specific overrides).
        -- E.g.: opts = { equivalence_classes = {} }
        opts = {},
      })
    end,
  },
})
