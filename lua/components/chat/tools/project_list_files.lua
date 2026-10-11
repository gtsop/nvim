local state = require("state")
local utils = require("utils")

local function exec(args)
  local project_dir = state.get_project_dir()
  local files = utils.list_dir_files(project_dir, true)

  return table.concat(files, "\n")
end

local name = "project.list_files"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.list_files",
    description = "Returns a string containing all project file paths, separated by newlines.",
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
