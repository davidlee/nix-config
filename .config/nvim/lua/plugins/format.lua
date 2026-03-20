local lz = require("lze")

lz.load({
  {
    "conform.nvim",
    after = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
          nix = { "alejandra" },
          go = { "goimports", { "gofumpt", "gofmt", stop_after_first = true } },
          rust = { "rustfmt" },
          zig = { "zigfmt" },
          python = { "ruff_format" },
          javascript = { "prettierd" },
          typescript = { "prettierd" },
          typescriptreact = { "prettierd" },
          javascriptreact = { "prettierd" },
          css = { "prettierd" },
          html = { "prettierd" },
          json = { "prettierd" },
          yaml = { "prettierd" },
          markdown = { "prettierd" },
          ["*"] = { "codespell" },
          ["_"] = { "trim_whitespace" },
        },
        default_format_opts = {
          lsp_format = "fallback",
        },
        notify_on_error = true,
        notify_no_formatters = true,
        format_on_save = {
          timeout_ms = 800,
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
