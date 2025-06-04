-- checkmate (nvim install from GitHub)
require("mini.deps").add({
  source = "bngarren/checkmate.nvim",
  ft = "markdown",
})

require("mini.deps").now(function()
  require("checkmate").setup({
    ft = "markdown",
    enabled = true,
    files = {
      "*", -- turn it on in files !~ /todo/
    },
  }) --
end)
