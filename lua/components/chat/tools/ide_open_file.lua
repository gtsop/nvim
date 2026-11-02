local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local path, err = shared.resolve_project_path(args.path or "", { must_exist = true })
  if err then
    return err
  end
  if vim.fn.filereadable(path) ~= 1 then
    return "ArgError: file does not exist"
  end

  local line = shared.tonumber_arg(args.line, 1)
  if line < 1 then
    line = 1
  end

  if not ide or not ide.edit then
    return "Error: ide.edit is unavailable"
  end

  ide.edit(path, line)
  return string.format("Opened %s at line %d", shared.relativize(path), line)
end

local name = "ide.open_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "ide.open_file",
    description = "Open a project file in the editor at an optional line.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Project file path.",
        },
        line = {
          type = "number",
          description = "1-based line to jump to (default 1).",
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
