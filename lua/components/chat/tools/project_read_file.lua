local is_file = require("utils.fs.is_file")
local read_file = require("utils.fs.read_file")

local function exec(args, ide)
  local path = args.path or args.file_path or ""
  if ide.is_project_file(path) then
    return read_file(args.path)
  else
    return "ArgError: 'path' does not contain a valid file path"
  end
end

local name = "project.read_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.read_file",
    description = "Reads a single project file and returns its contents.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "The path of the project file to read.",
        },
      },
      required = { "path" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
