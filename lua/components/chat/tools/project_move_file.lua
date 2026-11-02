local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local src_label = args.path
  local dst, err = shared.rename_path(args.path or "", args.new_path or "")
  if err then
    return err
  end
  return string.format("Moved %s -> %s", shared.relativize(src_label), shared.relativize(dst))
end

local name = "project.move_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.move_file",
    description = "Rename or move a path within the project.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Source path.",
        },
        new_path = {
          type = "string",
          description = "Destination path (must stay under project).",
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
