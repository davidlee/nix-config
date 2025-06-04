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
require("mini.deps").now(function() require("lsp-file-operations").setup() end)

--
require("lze").load({
  "triptych.nvim",
  after = function()
    require("triptych").setup({
      mappings = {
        nav_left = { "h", "<left>" },
        nav_right = { "l", "i", "<right>", "<CR>" }, -- If target is a file, opens the file in-place
      },
    })
  end,
})

-- neo-tree really doesn't want to be lazy loaded
require("neo-tree").setup({
  -- NOTE: without this, tabbing between netrw / snacks.picker will open a bonus neotree
  -- regardless of whether we've required neo-tree.
  filesystem = {
    hijack_netrw_behavior = "disabled",
  },
})

-- oil don't wanna lazy load
require("oil").setup()
