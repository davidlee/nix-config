-- open a note in obsidian; if it doesn't exist, ask Obsidian to create it first
local open_obsidian_note = function(rel_path)
  -- we need the abs_path to check if it exists
  -- or to open it in nvim
  local abs_path = vim.env.OBS_VAULT_PATH .. "/" .. rel_path
  -- if it doesn't exist, create it in Obsidian to make use of Obsidian's templating
  if vim.fn.file_readable(abs_path) == 0 then
    print("creating " .. rel_path .. " in obsidian")
    local uri = "obsidian://new?vault=" .. vim.env.OBS_VAULT .. "&file=" .. rel_path
    os.execute("open -g '" .. uri .. "'")
    os.execute("sleep 1") -- crudely await obsidian
  end

  -- now open it
  vim.cmd("edit " .. abs_path)
end

local sh = function(cmd)
  local handle = io.popen(cmd)
  local output = handle:read("*a")
  handle:close()
  return output
end

date_with_format = function(fmt_str)
  -- strip whitespace & return the formatted date
  -- (or current obsidian periodic note path)
  return sh("date +" .. fmt_str .. ' | tr -d " \\n"')
end

vim.api.nvim_create_user_command("Daily", function()
  rel_path = date_with_format(vim.env.OBS_DAY_NOTE_FORMAT)
  open_obsidian_note(rel_path)
end, {})

vim.api.nvim_create_user_command("Weekly", function()
  rel_path = date_with_format(vim.env.OBS_WEEK_NOTE_FORMAT)
  open_obsidian_note(rel_path)
end, {})
