-- movement
require("lze").load({
  --
  -- leap
  --
  -- {
  --   "leap.nvim",
  --   after = function()
  --     require("leap").set_default_mappings()
  --     -- Exclude whitespace and the middle of alphabetic words from preview:
  --     --   foobar[baaz] = quux
  --     --   ^----^^^--^^-^-^--^
  --     require("leap").opts.preview_filter = function(ch0, ch1, ch2)
  --       return not (ch1:match("%s") or ch0:match("%a") and ch1:match("%a") and ch2:match("%a"))
  --     end
  --   end,
  -- },

  -- -- flit
  -- {
  --   "flit.nvim",
  --   after = function()
  --     require("flit").setup({
  --       keys = { f = "f", F = "F", t = "t", T = "T" },
  --       -- A string like "nv", "nvo", "o", etc.
  --       labeled_modes = "v",
  --       -- Repeat with the trigger key itself.
  --       clever_repeat = true,
  --       multiline = true,
  --       -- Like `leap`s similar argument (call-specific overrides).
  --       -- E.g.: opts = { equivalence_classes = {} }
  --       opts = {},
  --     })
  --   end,
  -- },

  -- flash
  {
    "flash.nvim",
    keys = require("config.keymap").flash.keys,
    after = function() require("flash").setup() end,
  },
  -- ` bldc v j you, \
  --   nrts g p haei /
  --   xqmw z k f';.
  {
    -- aerial
    "aerial.nvim",
    after = function()
      local aerial = require("aerial")

      aerial.setup({
        -- use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,

        -- set a keymap to toggle aerial
        vim.keymap.set("n", "<leader>ua", "<cmd>AerialToggle!<CR>"),
      })
    end,
  },
})
