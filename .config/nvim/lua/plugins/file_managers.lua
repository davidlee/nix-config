--
-- File managers
--
-- note: see snacks.lua for Snacks.picker & Snacks.explorer, our main file manager

-- yazi
require("lze").load({
  "yazi.nvim",
  after = function()
    --
    require("plenary")
    require("yazi")
  end,
})

require("mini.deps").add({ source = "antosha417/nvim-lsp-file-operations" })
require("mini.deps").later(function() require("lsp-file-operations").setup() end)

-- triptych
require("lze").load({
  "triptych.nvim",
  after = function()
    require("triptych").setup({
      mappings = require("config.keymap").triptych.mappings,
    })
  end,
})

-- neo-tree: really doesn't want to be lazy loaded
require("neo-tree").setup({
  -- NOTE: without this, tabbing between netrw / snacks.picker will open a bonus neotree
  -- regardless of whether we've required neo-tree.
  filesystem = {
    hijack_netrw_behavior = "disabled",
  },
})

-- oil: don't wanna lazy load either
require("oil").setup()
