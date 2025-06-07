-- local md = require("mini.deps")
local lz = require("lze")

lz.load({
  -- lint
  "nvim-lint",
  after = function()
    local lint = require("lint")
    -- more: https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file
    lint.linters_by_ft = {
      markdown = { "vale" },
      elixir = { "credo" },
      typescript = { "eslint" },
      javascript = { "eslint" },
      rust = { "clippy" },
      nix = { "nix" },
      ruby = { "rubocop" },
      json = { "yq" },
      zsh = { "zsh" },
      lua = { "selene" },
      python = { "ruff" },
      html = { "tidy" },
    }
  end,
})

-- onsave autocmd
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require("lint").try_lint()

    -- You can call `try_lint` with a linter name or a list of names to always
    -- run specific linters, independent of the `linters_by_ft` configuration
    -- require("lint").try_lint("cspell")
  end,
})
