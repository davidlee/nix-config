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
  bullet = {
    enabled = true,
    icons = { "-", "", "", "", "󰨕" },
  },
  heading = {
    position = "inline",
    icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
  },
  checkbox = {
    -- checked = { raw = "[x]", },
    custom = {
      wip = { raw = "[/]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
      defer = { raw = "[>]", rendered = "󰃮 ", highlight = "RenderMarkdownOk", scope_highlight = nil },
      delegate = { raw = "[<]", rendered = "󰚎 ", highlight = "RenderMarkdownOk", scope_highlight = nil },
      question = { raw = "[?]", rendered = " ", highlight = "DiagnosticHint", scope_highlight = nil },
      info = { raw = "[i]", rendered = " ", highlight = "RenderMarkdownInfo", scope_highlight = nil },
      star = { raw = "[*]", rendered = " ", highlight = "DiagnosticWarn", scope_highlight = nil },
      todo = { raw = "[_]" }, -- don't clobber [-]
      important = {
        raw = "[!]",
        rendered = " ",
        highlight = "RenderMarkdownWarn",
        -- scope_highlight = nil,
      },
      cancel = {
        raw = "[-]",
        rendered = "󰜺 ",
        highlight = "RenderMarkdownWarn",
        scope_highlight = "@markup.strikethrough",
      },
    },
  },
  preset = "obsidian",
})

Snacks.scroll.disable() -- fix shitty performance
