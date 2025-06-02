require("lze").load({
  -- toggleterm
  "toggleterm.nvim",
  after = function()
    require("toggleterm").setup({
      --
      open_mapping = [[<c-\>]],
    })
  end,
})
