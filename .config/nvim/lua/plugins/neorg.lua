require("lze").load({
  {
    "neorg",
    lazy = false,
    after = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/neorg",
              },
            },
          },
        },
      })
    end,
  },
})
