local write_file = require("utils.fs.write_file")

local function exec(args, ide)
  local path = args.path or args.file_path or ""
  local content = args.content or ""

  if ide.is_project_file(path) then
    write_file(path, content)
    return string.format("Successfully wrote to %s", path)
  else
    return "ArgError: 'path' is not a valid project file or does not exist within the project"
  end
end

local name = "project.write_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.write_file",
    description = "Writes content to an existing project file. It will only write if the file is already within the project.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "The path of the project file to write to.",
        },
        content = {
          type = "string",
          description = "The content to write to the file.",
        },
      },
      required = { "path", "content" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
