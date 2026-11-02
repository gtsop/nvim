local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local src_label = args.path
  local dst, err = shared.copy_file(args.path or "", args.new_path or "")
  if err then
    return err
  end
  return string.format("Copied %s -> %s", shared.relativize(src_label), shared.relativize(dst))
end

local name = "project.copy_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.copy_file",
    description = "Copy a file to a new path within the project.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Source file path.",
        },
        new_path = {
          type = "string",
          description = "Destination file path.",
        },
      },
      required = { "path", "new_path" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
