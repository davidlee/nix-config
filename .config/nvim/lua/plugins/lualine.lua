return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "snacks.nvim",
    },
    -- opts = {},
    opts = function(_, opts)
      -- table.insert(opts.sections.lualine_x, {
      --   function()
      --     return "😄"
      --   end,
      -- })
    end,
  },
}
