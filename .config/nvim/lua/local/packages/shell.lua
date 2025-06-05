-- util: execute a shell command and return the result string, ignoring the
-- exit code and trimming all whitespace
--

local M = {}

function M.sh_word(cmd)
  -- note: xargs, amusingly, is the cleanest way to strip spaces in the shell
  local handle = io.popen(cmd .. ' | xargs | tr -d "\\n"')
  local output = handle:read("*a")
  handle:close()
  return output
end

return M
