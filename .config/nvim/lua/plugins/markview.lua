-- DISABLED
if true then
  return {}
end

return {
  --
  -- Markview
  --
  {
    "OXY2DEV/markview.nvim",
    lazy = false,

    opts = {
      preview = {
        icon_provider = "mini", -- "mini" or "devicons"
      },
    },

    dependencies = {
      "saghen/blink.cmp",
    },
  },
}
