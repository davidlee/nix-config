require("lze").load({
  -- aerial
  "aerial.nvim",
  after = function()
    local aerial = require("aerial")

    aerial.setup({
      -- use on_attach to set keymaps when aerial has attached to a buffer
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,

      -- set a keymap to toggle aerial
      vim.keymap.set("n", "<leader>ua", "<cmd>AerialToggle!<CR>"),
    })
  end,
})
