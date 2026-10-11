local state = require("state")
local utils = require("utils")

local function name()
  return "project.list_files"
end

local function desc()
  return [[
Tool: "project.list_files"
Returns a string containing all the files of the project seperated by new line
@param {string} as - Name of the variable to store the response of the LLM
@example
{ "name": "project.list_files", "args": { "as": "project_files" } }
]]
end

local function exec(args, vars, engine, callback)
  local project_dir = state.get_project_dir()
  local files = utils.list_dir_files(project_dir, true)

  vars[args.as] = table.concat(files, "\n")
  callback()
end

return {
  desc = desc,
  exec = exec,
  name = name,
  on = true,
}
