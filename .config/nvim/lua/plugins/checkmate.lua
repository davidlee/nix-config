-- checkmate
require("lze").load({
  "checkmate.nvim",
  after = function()
    require("checkmate").setup({
      ft = "markdown",
      enabled = true,
      files = {
        "*",
      },
    })
  end,
})
