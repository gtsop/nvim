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

  local start_line = shared.tonumber_arg(args.start_line, nil)
  local end_line = shared.tonumber_arg(args.end_line, start_line)
  if not start_line or start_line < 1 then
    return "ArgError: 'start_line' must be a 1-based line number"
  end
  if not end_line or end_line < start_line then
    return "ArgError: 'end_line' must be >= start_line"
  end

  local lines, read_err = shared.read_lines(path)
  if read_err then
    return read_err
  end

  if start_line > #lines then
    return string.format("ArgError: start_line %d past end (%d lines)", start_line, #lines)
  end
  if end_line > #lines then
    end_line = #lines
  end

  local new_lines = {}
  for i = 1, start_line - 1 do
    table.insert(new_lines, lines[i])
  end
  for i = end_line + 1, #lines do
    table.insert(new_lines, lines[i])
  end

  local write_err = shared.write_lines(path, new_lines)
  if write_err then
    return write_err
  end
  return string.format(
    "Deleted lines %d-%d (%d line(s)) from %s",
    start_line,
    end_line,
    end_line - start_line + 1,
    shared.relativize(path)
  )
end

local name = "project.delete_lines"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.delete_lines",
    description = "Delete an inclusive line range from a project file.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Project file path.",
        },
        start_line = {
          type = "number",
          description = "1-based start line (inclusive).",
        },
        end_line = {
          type = "number",
          description = "1-based end line (inclusive). Defaults to start_line.",
        },
      },
      required = { "path", "start_line" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
