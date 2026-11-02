local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  local most_recent_path = nil
  local most_recent_time = -1

  for _, buf in ipairs(vim.fn.getbufinfo()) do
    local bufnr = buf.bufnr
    local path = buf.name

    if
      vim.api.nvim_buf_is_valid(bufnr)
      and vim.bo[bufnr].buftype == ""
      and path ~= ""
      and vim.fn.filereadable(path) == 1
      and shared.is_under_project(path)
      and buf.lastused > most_recent_time
    then
      most_recent_path = path
      most_recent_time = buf.lastused
    end
  end

  if not most_recent_path then
    return "No project file is currently being edited"
  end
  return shared.relativize(most_recent_path)
end

local name = "ide.get_current_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "ide.get_current_file",
    description = "Returns the project-relative path of the most recently active project file buffer.",
    parameters = {
      type = "object",
      properties = vim.empty_dict(),
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
