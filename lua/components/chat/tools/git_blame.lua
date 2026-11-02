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
    return "ArgError: 'start_line' is required"
  end
  local end_line = shared.tonumber_arg(args.end_line, start_line)
  if end_line < start_line then
    return "ArgError: end_line must be >= start_line"
  end

  local range = string.format("%d,%d", start_line, end_line)
  local result, run_err = shared.run_git({
    "blame",
    "-L",
    range,
    "--",
    path,
  }, { path_args = { path } })
  if run_err then
    return run_err
  end
  if result.code ~= 0 then
    return "Error: git blame failed: "
      .. shared.truncate_text(result.stderr ~= "" and result.stderr or result.stdout, 1000)
  end
  return shared.truncate_text(vim.trim(result.stdout), args.max_bytes)
end

local name = "git.blame"

local schema = {
  type = "function",
  ["function"] = {
    name = "git.blame",
    description = "Git blame for a line range in a project file.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Project file path.",
        },
        start_line = {
          type = "number",
          description = "1-based start line.",
        },
        end_line = {
          type = "number",
          description = "1-based end line (default start_line).",
        },
        max_bytes = {
          type = "number",
          description = "Hard cap on returned bytes.",
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
