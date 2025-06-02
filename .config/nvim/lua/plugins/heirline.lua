-- TODO: heirline config
--
require("lze").load({
  -- heirline
  "heirline.nvim",
  after = function()
    require("heirline").setup({
      --
    })
  end,
})
