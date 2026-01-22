local md = require("mini.deps")
local lz = require("lze")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#zls

-- nix
vim.lsp.enable("nixd")

-- go
vim.lsp.enable("gopls")

-- markdown
lz.load({
  {
    "nvim-lspconfig",
    after = function()
      -- require("lspconfig")["marksman"].setup({
      --   --
      -- })
      -- require("lspconfig")["lua_ls"].setup({})
    end,
  },
})

-- eagle (diagnostics + LSP info on cursor)
md.add({ source = "soulis-1256/eagle.nvim" })

md.later(function() require("eagle").setup({}) end)

-- lua
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- Depending on the usage, you might want to add additional paths
          -- here.
          -- '${3rd}/luv/library'
          -- '${3rd}/busted/library'
        },
        -- Or pull in all of 'runtimepath'.
        -- NOTE: this is a lot slower and will cause issues when working on
        -- your own configuration.
        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
        -- library = {
        --   vim.api.nvim_get_runtime_file('', true),
        -- }
      },
    })
  end,
  settings = {
    Lua = {},
  },
})

-- marksman
vim.lsp.enable("marksman")

vim.lsp.enable("markdown-oxide")
-- rust
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = false,
      },
    },
  },
})

-- zls / zig
vim.lsp.enable("zls", {
  cmd = { "zls" },
  filetypes = { "zig", "zir" },
  -- root_dir = lspconfig.util.root_pattern("build.zig", ".git") or vim.loop.cwd,
  single_file_support = true,
})
vim.g.zig_fmt_autosave = 1

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- Go to definition
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- Hover info
  end,
})

-- zk
-- vim.lsp.enable("zk")

-- tailwindCSS
vim.lsp.enable("tailwindcss")

-- TOML / taplo
vim.lsp.enable("taplo")

-- text
vim.lsp.enable("textlsp")
vim.lsp.enable("vale_ls")

-- typescript
vim.lsp.config("ts_ls", {
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
        languages = { "javascript", "typescript", "vue" },
      },
    },
  },
  filetypes = {
    "javascript",
    "typescript",
    -- "vue",
  },
})

-- eslint
vim.lsp.enable("eslint")

-- css variables
vim.lsp.enable("css_variables")

-- basics (buffer,path,snippets)
vim.lsp.enable("basics_ls")

-- bash
vim.lsp.enable("bashls")

-- ast-grep
vim.lsp.enable("ast_grep")

-- yaml
vim.lsp.enable("yamlls")
