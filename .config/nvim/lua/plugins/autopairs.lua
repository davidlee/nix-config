-- autopairs
require("lze").load({
  -- autopairs
  "nvim-autopairs",
  event = "InsertEnter",
  after = function()
    require("nvim-autopairs").setup({
      --
      check_ts = true,
      -- enabled = function(bufnr) return require("astrocore.buffer").is_valid(bufnr) end,
      -- enabled = function(bufnr) return true end,
      ts_config = { java = false },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = ([[ [%'%"%)%>%]%)%}%,] ]]):gsub("%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    })
  end,
})
