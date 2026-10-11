local is_file = require("utils.fs.is_file")
local read_file = require("utils.fs.read_file")

local function name()
  return "project.read_file"
end

local function desc()
  return [[
Tool: "project.read_file"
Reads a single project file and returns it's contents
@param {string} path - The path of the file to be read
@param {string} as - Name of the variable to store the response of the LLM
@example
{ "name": "project.read_file", "args": { "path": "<some file path you need to read"", "as": "file_contents" } }
]]
end

local function exec(args, vars, engine, callback)
  local path = engine.replace_variables(args.path or args.file_path or "")
  if not is_file(path) then
    vars[args.as] = "ArgError: 'path' does not contain a valid file path"
  else
    vars[args.as] = read_file(args.path)
  end
  callback()
end

return {
  desc = desc,
  exec = exec,
  name = name,
  on = true,
}
