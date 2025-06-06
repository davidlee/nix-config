local md = require("mini.deps")
local lz = require("lze")

--
-- File managers
--
-- note: see snacks.lua for Snacks.picker & Snacks.explorer, our main file manager

-- yazi
lz.load({
  "yazi.nvim",
  after = function()
    --
    require("plenary")
    require("yazi")
  end,
})

md.add({ source = "antosha417/nvim-lsp-file-operations" })
md.later(function() require("lsp-file-operations").setup() end)

-- triptych
lz.load({
  "triptych.nvim",
  after = function()
    require("triptych").setup({
      mappings = require("config.keymap").triptych.mappings,
    })
  end,
})

-- TODO: get Oil, Neo-Tree loading again

-- neo-tree: really doesn't want to be lazy loaded
-- require("neo-tree").setup({
--   -- NOTE: without this, tabbing between netrw / snacks.picker will open a bonus neotree
--   -- regardless of whether we've required neo-tree.
--   filesystem = {
--     hijack_netrw_behavior = "disabled",
--   },
-- --- Fix neotree
-- require("neo-tree.setup.netrw")
-- vim.g.neotree_watching_bufenter = 0
-- vim.g.hijack_netrw_behavior = 0- })

-- oil: don't wanna lazy load either
-- require("oil").setup()
