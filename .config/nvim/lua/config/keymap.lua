-----------------------------------------------------
--- Leader Key Groups
-----------------------------------------------------
require("which-key").add({
  -- add headings
  { "<leader>f", group = "File" },
  { "<leader>b", group = "Buffer" },
  { "<leader>g", group = "Git" },
  { "<leader>s", group = "Search" },
  { "<leader>r", group = "SurRound" },
  { "<leader>u", group = "Toggle" },
  { "<leader>y", group = "Clipboard" },
})

-----------------------------------------------------
--- Keymap Config Table
-----------------------------------------------------
-- export a table to consolidate binds in this file
-- while allowing them to be set up elsewhere (e.g. lazy loaded plugins)

local Keys = {
  snacks = {
    keys = {
      -- Toggles
      { "<leader>ut", function() Snacks.terminal.toggle() end, desc = "Toggle terminal" },
      { "<leader>u.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      -- Favourite Pickers & Explorer (single char bindings)
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
      { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { '<leader>R"', function() Snacks.picker.registers() end, desc = "Registers" },
      -- find
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      {
        "<leader>fc",
        function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
        desc = "Find Config File",
      },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
      -- git
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
      -- Grep
      -- search
      { "<leader>s/", function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Vis selection or word", mode = { "n", "x" } },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
      { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
      -- LSP
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
      -- Toggle
      { "<leader>uz", function() Snacks.zen() end, desc = "Toggle zen mode" },
      { "<leader>uZ", function() Snacks.zen.zoom() end, desc = "Toggle zen zoom mode" },
      -- bufdelete
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Buffer > delete" },
      -- toggle terminal
    },
  },
  aerial = {
    on_attach = function(bufnr)
      -- Jump forwards/backwards with '{' and '}'
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
    end,
  },
  triptych = {
    mappings = {
      nav_left = { "h", "<left>" },
      nav_right = { "l", "i", "<right>", "<CR>" }, -- If target is a file, opens the file in-place
    },
  },
  flash = {
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  mini_surround = {
    mappings = {
      add = "<leader>ra", -- Add surrounding in Normal and Visual modes
      delete = "<leader>rd", -- Delete surrounding
      find = "<leader>rf", -- Find surrounding (to the right)
      find_left = "<leader>rF", -- Find surrounding (to the left)
      highlight = "<leader>rh", -- Highlight surrounding
      replace = "<leader>rr", -- Replace surrounding
      update_n_lines = "<leader>rn", -- Update `n_lines`

      suffix_last = "l", -- Suffix to search with "prev" method
      suffix_next = "n", -- Suffix to search with "next" method
    },
  },
  which_key = {
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer Local Keymaps (which-key)",
      },
      {
        "<leader><f1>",
        function() require("which-key").show({ global = true }) end,
        desc = "Global Keymaps (which-key)",
      },
    },
  },
}

-----------------------------------------------------
--- Keymap Bindings
-----------------------------------------------------
local bind = vim.keymap.set
-----------------------------------------------------
-- bind {mode} args:
-- (n)orm (i)ns (x)norm/ins
-- (c)md (v)is (s)elect
-- (o)per (t)erm (l)ang
-- '' :map = nvo
-- ! :map! = ic
-----------------------------------------------------

-----------------------------------------------------
--- Normal Mode bindings:
-----------------------------------------------------

-- X: delete char without yank
bind({ "n", "x" }, "X", '"_x', { desc = "delete char without yank" })

-- Alt-PgUp/Dn: buffer next/prev
bind("", "<A-PageDown>", "<cmd>bp<cr>", { desc = "Buffer > next" })
bind("", "<A-PageUp>", "<cmd>bn<cr>", { desc = "Buffer > prev" })

-----------------------------------------------------
--- Leader Mode single char bindings:
-----------------------------------------------------
-- !: write file
bind("n", "<space>!", "<cmd>write<cr>", { desc = "Save" })

-----------------------------------------------------
--- Leader Mode multi-key bindings:
-----------------------------------------------------

--- Clipboard --------------------
-- yy: system clipboard: copy
bind({ "n", "x" }, "<leader>yy", '"+y', { desc = "Yank to system clipboard" })

-- yp: system clipboard: paste
bind({ "n", "x" }, "<leader>yp", '"+p', { desc = "Paste to system clipboard" })

-- ya: select entire buffer
bind("n", "<leader>ya", ":keepjumps normal! ggVG<cr>", { desc = "Select entire buffer" })

--- File Managers --------------------
-- f-: (:Triptych)
bind("n", "<leader>f-", "<cmd>Triptych<cr>", { silent = true, desc = "Toggle Triptych" })
-- fo: (:Oil)
bind("n", "<leader>fo", "<cmd>Oil<cr>", { silent = true, desc = "Oil (:Oil)" })
-- fE: (:Ex) Explore with NetRW
bind("n", "<leader>fE", "<cmd>Ex<cr>", { desc = "NetRW (:Ex)" })
-- fy: (:Yazi) open in Yazi
bind("n", "<leader>fy", "<cmd>Yazi<cr>", { desc = "Yazi (:Yazi)" })

-- Aerial --------------------
-- set a keymap to toggle aerial
bind("n", "<leader>ua", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial" })

-----------------------------------------------------
--- [ / ] mode bindings
-----------------------------------------------------
-- Todo-Comments --------------------
bind("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next todo comment" })
bind("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous todo comment" })

-- Yanky (shadows built-ins) -------
bind({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Yanky put (after)" })
bind({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Yanky put (before)" })
bind({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { desc = "Yanky gput (after)" })
bind({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { desc = "Yanky gput (after)" })

bind("n", "<c-p>", "<Plug>(YankyPreviousEntry)", { desc = "Yanky prev entry" })
bind("n", "<c-n>", "<Plug>(YankyNextEntry)", { desc = "Yanky next entry" })

-----------------------------------------------------
--- Misc
-----------------------------------------------------

-------------------------------------------
--- move lines up / down
-------------------------------------------
-- normal mode
bind("n", "<A-j>", "<cmd>m .+1<cr>", { desc = "Move line down" })
bind("n", "<A-k>", "<cmd>m .-2<cr>", { desc = "Move line up" })
-- insert mode
bind("i", "<A-j>", "<esc>:m .+1<cr>==gi", { desc = "Move line down" })
bind("i", "<A-k>", "<esc>:m .-2<cr>==gi", { desc = "Move line up" })
-- visual mode
bind("v", "<A-j>", "<cmd>m '>+1<cr>gv=gv", { desc = "Move selected lines down" })
bind("v", "<A-k>", "<cmd>m '<-2<cr>gv=gv", { desc = "Move selected lines up" })

--- export the key table for use elsewhere
return Keys
