require("lze").load({
  -- render-markdown
  {
    "render-markdown.nvim",
    after = function()
      print("render-markdown")
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
    end,
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  },
})
