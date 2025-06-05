-- open a note in obsidian; if it doesn't exist, ask Obsidian to create it first
local open_obsidian_note = function(date_format_string)
  -- get both the relative and absolute paths for the note; we may need both
  local cmd = "date +" .. date_format_string .. ' | tr -d " \\n"'
  local handle = io.popen(cmd)
  local rel_path = handle:read("*a")
  local abs_path = vim.env.OBS_DIR .. "/" .. rel_path
  handle:close()

  -- if file doesn't exist, create it in obsidian to make use of its templating
  if vim.fn.file_readable(abs_path) == 0 then
    print("creating " .. rel_path .. " in obsidian")
    local uri = "obsidian://new?vault=workbench&file=" .. rel_path
    print(uri)
    os.execute("open -g '" .. uri .. "'")
    os.execute("sleep 2") -- crudely await obsidian
  end

  -- now open it
  vim.cmd("edit " .. abs_path)
end

vim.api.nvim_create_user_command("Daily", function() open_obsidian_note(vim.env.OBS_DAY_NOTE_FORMAT) end, {})
vim.api.nvim_create_user_command("Weekly", function() open_obsidian_note(vim.env.OBS_WEEK_NOTE_FORMAT) end, {})
