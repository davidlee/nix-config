-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- extra plugins
--
require("oil").setup()

Snacks.scroll.disable() -- fix shitty performance

-- require("orgmode").setup({})
