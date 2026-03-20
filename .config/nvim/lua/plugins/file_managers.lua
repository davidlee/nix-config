local lz = require("lze")

--
-- File managers
--
-- note: see snacks.lua for Snacks.picker & Snacks.explorer, our main file manager

-- yazi
lz.load({
  "yazi.nvim",
  after = function()
    require("plenary")
    require("yazi")
  end,
})

lz.load({
  "nvim-lsp-file-operations",
  after = function() require("lsp-file-operations").setup() end,
})

-- triptych
lz.load({
  "triptych.nvim",
  after = function()
    require("triptych").setup({
      mappings = require("config.keymap").triptych.mappings,
    })
  end,
})

require("neo-tree").setup({
  -- prevent neotree from hijacking netrw (snacks.explorer is primary)
  filesystem = {
    hijack_netrw_behavior = "disabled",
  },
})

-- oil: not lazy loaded
require("oil").setup()
