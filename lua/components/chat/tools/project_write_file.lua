local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local path, err = shared.resolve_project_path(args.path or args.file_path or "")
  if err then
    return err
  end

  local content = args.content
  if content == nil then
    return "ArgError: 'content' is required"
  end

  local create = shared.truthy(args.create)
  local exists = vim.fn.filereadable(path) == 1

  if not exists and not create then
    return "ArgError: file does not exist; pass create=true to create it, or use project.create_file"
  end

  local _, write_err = shared.write_file(path, content)
  if write_err then
    return write_err
  end
  return string.format("Successfully wrote %d bytes to %s", #tostring(content), shared.relativize(path))
end

local name = "project.write_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.write_file",
    description = "Overwrite an entire project file. Prefer project.apply_edit for small changes. Set create=true to create a missing file.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Project file path to write.",
        },
        content = {
          type = "string",
          description = "Full new file contents.",
        },
        create = {
          type = "boolean",
          description = "If true, create the file (and parents) when missing. Default false.",
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
