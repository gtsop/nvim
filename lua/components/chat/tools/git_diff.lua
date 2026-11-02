local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local git_args = { "diff", "--no-color" }
  local path_args = nil

  if shared.truthy(args.staged) then
    table.insert(git_args, "--cached")
  end

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
    return "Error: git diff failed: "
      .. shared.truncate_text(result.stderr ~= "" and result.stderr or result.stdout, 1000)
  end

  if vim.trim(result.stdout) == "" then
    return "(no diff)"
  end

  local lines = {}
  for line in result.stdout:gmatch("[^\n]+") do
    table.insert(lines, line)
  end

  local offset = shared.tonumber_arg(args.offset, 0)
  local limit = shared.tonumber_arg(args.limit, 200)
  local slice, total, remaining = shared.paginate(lines, offset, limit)
  local body = table.concat(slice, "\n")
  if remaining > 0 then
    body = body
      .. string.format("\n... truncated (%d more of %d lines; use offset/limit)", remaining, total)
  end
  return shared.truncate_text(body, args.max_bytes)
end

local name = "git.diff"

local schema = {
  type = "function",
  ["function"] = {
    name = "git.diff",
    description = "Show git diff (unstaged by default). Use path and offset/limit to keep output small.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Optional path to diff.",
        },
        staged = {
          type = "boolean",
          description = "If true, show staged (--cached) diff.",
        },
        offset = {
          type = "number",
          description = "0-based line offset into diff output.",
        },
        limit = {
          type = "number",
          description = "Max diff lines (default 200).",
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
