local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local del_err = shared.delete_path(args.path or "")
  if del_err then
    return del_err
  end
  return "Deleted " .. shared.relativize(args.path)
end

local name = "project.delete_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.delete_file",
    description = "Delete a file or directory within the project. Refuses paths outside the project.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Path to delete.",
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
