local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local path, err = shared.resolve_project_path(args.path or args.file_path or "")
  if err then
    return err
  end
  if vim.fn.filereadable(path) ~= 1 then
    return "ArgError: 'path' does not contain a valid file path"
  end

  local lines, read_err = shared.read_lines(path)
  if read_err then
    return read_err
  end

  local total = #lines
  local start_line = shared.tonumber_arg(args.start_line, nil)
  local end_line = shared.tonumber_arg(args.end_line, nil)
  local offset = shared.tonumber_arg(args.offset, nil)
  local limit = shared.tonumber_arg(args.limit, shared.DEFAULTS.read_limit)

  if start_line then
    if start_line < 1 then
      start_line = 1
    end
    end_line = end_line or math.min(start_line + limit - 1, total)
  elseif offset ~= nil then
    start_line = offset + 1
    end_line = math.min(start_line + limit - 1, total)
  else
    start_line = 1
    end_line = math.min(limit, total)
  end

  if end_line > total then
    end_line = total
  end
  if start_line > total then
    return string.format("(file has %d lines; start_line %d is past end)", total, start_line)
  end

  local slice = {}
  for i = start_line, end_line do
    table.insert(slice, lines[i])
  end

  local body = string.format("lines %d-%d of %d\n%s", start_line, end_line, total, shared.format_lines(slice, start_line))
  local remaining = total - end_line
  if remaining > 0 then
    body = body
      .. string.format("\n... truncated (%d more lines; use start_line/end_line or offset/limit)", remaining)
  end

  return shared.truncate_text(body, args.max_bytes)
end

local name = "project.read_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.read_file",
    description = "Read a project file by line range. Defaults to the first 200 lines. Prefer start_line/end_line or offset/limit over reading entire large files.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Project file path (relative or absolute under project).",
        },
        start_line = {
          type = "number",
          description = "1-based start line (inclusive).",
        },
        end_line = {
          type = "number",
          description = "1-based end line (inclusive).",
        },
        offset = {
          type = "number",
          description = "0-based line offset alternative to start_line.",
        },
        limit = {
          type = "number",
          description = "Max lines to return (default 200).",
        },
        max_bytes = {
          type = "number",
          description = "Hard cap on returned bytes (default 32000).",
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
