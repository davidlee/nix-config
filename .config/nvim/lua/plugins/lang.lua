-- https://github.com/binhtran432k/dotfiles/blob/a264fce08dd931e40bf47bd364dc80a8e55cc1bb/nvim/lua/plugins/lang.lua#L46-L68
return {
  {
    "tree-sitter-grammars/tree-sitter-test",
    build = "mkdir parser && tree-sitter build -o parser/test.so",
    ft = "test",
    init = function()
      -- toggle full-width rules for test separators
      vim.g.tstest_fullwidth_rules = false
      -- set the highlight group of the rules
      vim.g.tstest_rule_hlgroup = "FoldColumn"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "css", "html" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        biome = {},
        cssls = {},
        html = {},
        tailwindcss = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "tailwind.config.js",
              "tailwind.config.cjs",
              "tailwind.config.mjs",
              "tailwind.config.ts"
            )(fname)
          end,
        },
        unocss = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = { "alejandra" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ensure_installed = {
        astro = true,
        tailwindcss = true,
        -- unocss = true,
        -- volar = true,
        -- vtsls = true,
      }
      for server, server_opts in pairs(opts.servers) do
        if type(server_opts) == "table" and not ensure_installed[server] then
          server_opts.mason = false
        end
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = { "markdown-toc" }
    end,
  },
}
