local shell = require("local.packages.shell")
local myos = require("local.packages.os")

local M = {}

-- open a note in obsidian; if it doesn't exist, ask Obsidian to create it first
-- this ensures Obsidian can handle templating
function M.create_or_edit(rel_path)
  -- we need the abs_path to check if it exists, or to open it in nvim
  local abs_path = vim.env.OBS_VAULT_PATH .. "/" .. rel_path
  -- if it doesn't exist, create it in Obsidian to make use of Obsidian's templating
  if vim.fn.file_readable(abs_path) == 0 then
    print("creating " .. rel_path .. " in obsidian")
    local uri = "obsidian://new?vault=" .. vim.env.OBS_VAULT .. "&file=" .. rel_path
    if myos.is_mac() then
      os.execute("open -g '" .. uri .. "'")
    else
      os.execute("xdg-open '" .. uri .. "'")
    end
    os.execute("sleep 1") -- crudely await obsidian
  end

  -- finally, open it in neovim
  vim.cmd("edit " .. abs_path)
end

-- takes a format string for the `date` shell command and returns a string
local function date_with_format(fmt_str)
  -- strip whitespace & return the formatted date
  -- (or current obsidian periodic note path)
  return shell.sh_word("date +" .. fmt_str)
end

--
-- Obsidian integration commands
--

-- :Daily - open (create if missing) daily note
vim.api.nvim_create_user_command("Daily", function()
  local rel_path = date_with_format(vim.env.OBS_DAY_NOTE_FORMAT)
  M.create_or_edit(rel_path)
end, {})

-- :Weekly - open (create if missing) daily note
vim.api.nvim_create_user_command("Weekly", function()
  local rel_path = date_with_format(vim.env.OBS_WEEK_NOTE_FORMAT)
  M.create_or_edit(rel_path)
end, {})

-- :Weekly - open (create if missing) daily note
vim.api.nvim_create_user_command("Monthly", function()
  local rel_path = date_with_format(vim.env.OBS_MONTH_NOTE_FORMAT)
  M.create_or_edit(rel_path)
end, {})

-- return {
--   create_or_edit,
--   util = {},
-- }

return M
