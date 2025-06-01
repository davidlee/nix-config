-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- extra plugins
--
require("oil").setup()

-- render-markdown
require("render-markdown").setup({
  indent = {
    completions = { blink = { enabled = true } },
  },
  heading = {
    position = "inline",
    icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
  },
  preset = "obsidian",
})

Snacks.scroll.disable() -- fix shitty performance
