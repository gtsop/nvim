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
  if not start_line or start_line < 1 then
    return "ArgError: 'start_line' must be a 1-based line number"
  end

  local content = args.content
  if content == nil then
    return "ArgError: 'content' is required"
  end

  local lines, read_err = shared.read_lines(path)
  if read_err then
    return read_err
  end

  if start_line > #lines + 1 then
    return string.format("ArgError: start_line %d is past end of file (%d lines)", start_line, #lines)
  end

  local insert = vim.split(tostring(content), "\n", { plain = true })
  local new_lines = {}
  for i = 1, start_line - 1 do
    table.insert(new_lines, lines[i])
  end
  for _, l in ipairs(insert) do
    table.insert(new_lines, l)
  end
  for i = start_line, #lines do
    table.insert(new_lines, lines[i])
  end

  local write_err = shared.write_lines(path, new_lines)
  if write_err then
    return write_err
  end
  return string.format(
    "Inserted %d line(s) at line %d in %s",
    #insert,
    start_line,
    shared.relativize(path)
  )
end

local name = "project.insert_lines"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.insert_lines",
    description = "Insert content before start_line (1-based) without rewriting the whole file.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Project file path.",
        },
        start_line = {
          type = "number",
          description = "1-based line number to insert before. Use total_lines+1 to append.",
        },
        content = {
          type = "string",
          description = "Text to insert (may contain newlines).",
        },
      },
      required = { "path", "start_line", "content" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
