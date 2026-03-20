-- local md = require("mini.deps")
local lz = require("lze")

require("mini.surround").setup({
  mappings = require("config.keymap").mini_surround.mappings,
})

require("plugins.autopairs")

-- editor
lz.load({
  -- yanky
  {
    "yanky.nvim",
    after = function() require("yanky").setup() end,
  },

  -- todo-comments
  {
    "todo-comments.nvim",
    after = function() require("todo-comments").setup({}) end,
  },

  {
    "auto-save.nvim",
    after = function()
      require("auto-save").setup({
        trigger_events = {
          immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
          defer_save = { "InsertLeave", "TextChanged" },
          cancel_deferred_save = { "InsertEnter" },
        },
        debounce_delay = 400,
        condition = function(buf)
          -- skip special buffers
          if vim.fn.getbufvar(buf, "&buftype") ~= "" then return false end
          return true
        end,
        write_all_buffers = false,
        noautocmd = true, -- prevents BufWritePre/Post firing, avoids undo break
      })
    end,
  },
})
