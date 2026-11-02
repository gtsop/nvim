local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local path, err = shared.resolve_project_path(args.path or "")
  if err then
    return err
  end

  if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
    return "ArgError: path already exists"
  end

  local _, write_err = shared.write_file(path, args.content or "")
  if write_err then
    return write_err
  end
  return string.format("Created %s", shared.relativize(path))
end

local name = "project.create_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.create_file",
    description = "Create a new project file (mkdir -p parents). Fails if the path already exists.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "New file path under the project.",
        },
        content = {
          type = "string",
          description = "Optional initial contents (default empty).",
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
