local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local limit = shared.tonumber_arg(args.limit, shared.DEFAULTS.git_log_limit)
  local git_args = {
    "log",
    "--oneline",
    "--no-color",
    "-n",
    tostring(limit),
  }
  local path_args = nil

  if args.path and args.path ~= "" then
    local resolved, err = shared.resolve_project_path(args.path)
    if err then
      return err
    end
    table.insert(git_args, "--")
    table.insert(git_args, resolved)
    path_args = { resolved }
  end

  local result, run_err = shared.run_git(git_args, { path_args = path_args })
  if run_err then
    return run_err
  end
  if result.code ~= 0 then
    return "Error: git log failed: "
      .. shared.truncate_text(result.stderr ~= "" and result.stderr or result.stdout, 1000)
  end

  if vim.trim(result.stdout) == "" then
    return "(no commits)"
  end
  return shared.truncate_text(vim.trim(result.stdout), args.max_bytes)
end

local name = "git.log"

local schema = {
  type = "function",
  ["function"] = {
    name = "git.log",
    description = "Show recent git commits (oneline). Default limit 10.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Optional path to scope history.",
        },
        limit = {
          type = "number",
          description = "Number of commits (default 10).",
        },
        max_bytes = {
          type = "number",
          description = "Hard cap on returned bytes.",
        },
      },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
