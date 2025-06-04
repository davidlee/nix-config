require("lze").load({
  { -- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#setup
    "conform.nvim",
    after = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" }, --  --indent-type Spaces --indent-width 2
          fish = { "fish_indent" },
          sh = { "shfmt" },
          nix = { "alejandra" },
          -- Conform will run multiple formatters sequentially
          go = { "goimports", "gofmt" },
          -- You can also customize some of the format options for the filetype
          rust = { "rustfmt", lsp_format = "fallback" },
          -- Use the "*" filetype to run formatters on all filetypes.
          ["*"] = { "codespell" },
          -- Use the "_" filetype to run formatters on filetypes that don't
          -- have other formatters configured.
          ["_"] = { "trim_whitespace" },
        },
        default_format_opts = {
          lsp_format = "fallback",
        },
        -- log_level = vim.log.levels.ERROR,
        notify_on_error = true,
        -- Conform will notify you when no formatters are available for the buffer
        notify_no_formatters = true,
        format_on_save = {
          -- I recommend these options. See :help conform.format for details.
          async = false,
          lsp_format = "fallback",
          timeout_ms = 800,
        },
        -- If this is set, Conform will run the formatter asynchronously after save.
        -- It will pass the table to conform.format().
        -- This can also be a function that returns the table.
        format_after_save = {
          lsp_format = "fallback",
        },
      })
    end,
  },
})

-- set up user command
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })
