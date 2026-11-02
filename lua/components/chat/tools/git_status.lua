local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local git_args = { "status", "--porcelain=v1", "-uall" }
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
    return "Error: git status failed: "
      .. shared.truncate_text(result.stderr ~= "" and result.stderr or result.stdout, 1000)
  end

  if vim.trim(result.stdout) == "" then
    return "(clean working tree)"
  end

  local lines = {}
  for line in result.stdout:gmatch("[^\n]+") do
    table.insert(lines, line)
  end

  local limit = shared.tonumber_arg(args.limit, 100)
  local slice, total, remaining = shared.paginate(lines, 0, limit)
  local body = table.concat(slice, "\n")
  if remaining > 0 then
    body = body .. string.format("\n... truncated (%d more of %d)", remaining, total)
  end
  return body
end

local name = "git.status"

local schema = {
  type = "function",
  ["function"] = {
    name = "git.status",
    description = "Show short git status (porcelain). Optionally scoped to a path.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Optional path to scope status.",
        },
        limit = {
          type = "number",
          description = "Max status lines (default 100).",
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
