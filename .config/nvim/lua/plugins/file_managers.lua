--
-- File managers
--
-- note: see snacks.lua for Snacks.picker & Snacks.explorer, our main file manager

--
require("lze").load({
  "triptych.nvim",
  after = function()
    require("triptych").setup({
      mappings = {
        nav_left = { "h", "<left>" },
        nav_right = { "l", "i", "<right>", "<CR>" }, -- If target is a file, opens the file in-place
      },
      -- keys = {
      --   { "<leader>-", ":Triptych<CR>" },
      -- },
    })
  end,
})

-- //

-- neo-tree really doesn't want to be lazy loaded
require("neo-tree").setup({
  -- without this, tabbing between netrw / snacks.picker will open a bonus neotree
  -- regardless of whether we've required neo-tree.
  --
  -- I'd like to know
  --
  filesystem = {
    hijack_netrw_behavior = "disabled",
  },
})

-- oil don't wanna lazy load
require("oil").setup()
