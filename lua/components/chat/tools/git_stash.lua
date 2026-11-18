local shared = require("components.chat.tools._shared")

local ACTIONS = {
  list = true,
  show = true,
  push = true,
  apply = true,
  pop = true,
  drop = true,
}

--- Parse a stash index from args. Accepts number or "stash@{n}" / "n".
local function stash_ref(args)
  local raw = args.index
  if raw == nil or raw == "" then
    return "stash@{0}", nil
  end

  if type(raw) == "number" then
    if raw < 0 or raw ~= math.floor(raw) then
      return nil, "ArgError: index must be a non-negative integer"
    end
    return string.format("stash@{%d}", raw), nil
  end

  if type(raw) ~= "string" then
    return nil, "ArgError: index must be a number or stash@{n}"
  end

  local n = raw:match("^%s*stash@%{(%d+)%}%s*$") or raw:match("^%s*(%d+)%s*$")
  if not n then
    return nil, "ArgError: index must be a non-negative integer or stash@{n}"
  end
  return string.format("stash@{%d}", tonumber(n)), nil
end

local function run_stash(git_args, opts)
  local result, run_err = shared.run_git(git_args, opts)
  if run_err then
    return run_err
  end
  if result.code ~= 0 then
    return "Error: git stash failed: "
      .. shared.truncate_text(result.stderr ~= "" and result.stderr or result.stdout, 1000)
  end
  local out = vim.trim(result.stdout)
  if out == "" then
    out = vim.trim(result.stderr)
  end
  return out ~= "" and out or "(ok)"
end

local function exec_list(args)
  local limit = shared.tonumber_arg(args.limit, 20)
  local result, run_err = shared.run_git({ "stash", "list" })
  if run_err then
    return run_err
  end
  if result.code ~= 0 then
    return "Error: git stash list failed: "
      .. shared.truncate_text(result.stderr ~= "" and result.stderr or result.stdout, 1000)
  end

  if vim.trim(result.stdout) == "" then
    return "(stash empty)"
  end

  local lines = {}
  for line in result.stdout:gmatch("[^\n]+") do
    table.insert(lines, line)
  end

  local slice, total, remaining = shared.paginate(lines, 0, limit)
  local body = table.concat(slice, "\n")
  if remaining > 0 then
    body = body .. string.format("\n... truncated (%d more of %d)", remaining, total)
  end
  return body
end

local function exec_show(args)
  local ref, err = stash_ref(args)
  if err then
    return err
  end

  local git_args = { "stash", "show", "--no-color" }
  if shared.truthy(args.patch) or args.patch == nil then
    -- Default to patch so the model can actually read stash contents.
    table.insert(git_args, "-p")
  end
  table.insert(git_args, ref)

  local path_args = nil
  if args.path and args.path ~= "" then
    local resolved, perr = shared.resolve_project_path(args.path)
    if perr then
      return perr
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
    return "Error: git stash show failed: "
      .. shared.truncate_text(result.stderr ~= "" and result.stderr or result.stdout, 1000)
  end

  if vim.trim(result.stdout) == "" then
    return "(empty stash entry)"
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

local function exec_push(args)
  local git_args = { "stash", "push" }
  if shared.truthy(args.include_untracked) then
    table.insert(git_args, "-u")
  end
  if args.message and args.message ~= "" then
    table.insert(git_args, "-m")
    table.insert(git_args, tostring(args.message))
  end

  local path_args = nil
  if args.path and args.path ~= "" then
    local resolved, perr = shared.resolve_project_path(args.path)
    if perr then
      return perr
    end
    table.insert(git_args, "--")
    table.insert(git_args, resolved)
    path_args = { resolved }
  end

  return run_stash(git_args, { path_args = path_args })
end

local function exec_apply_or_pop(args, action)
  local ref, err = stash_ref(args)
  if err then
    return err
  end
  return run_stash({ "stash", action, ref })
end

local function exec_drop(args)
  local ref, err = stash_ref(args)
  if err then
    return err
  end
  return run_stash({ "stash", "drop", ref })
end

local function exec(args, ide)
  args = args or {}
  local action = args.action
  if type(action) ~= "string" or action == "" then
    return "ArgError: 'action' is required (list|show|push|apply|pop|drop)"
  end
  action = action:lower()
  if not ACTIONS[action] then
    return "ArgError: unknown action: " .. tostring(args.action)
  end

  if action == "list" then
    return exec_list(args)
  elseif action == "show" then
    return exec_show(args)
  elseif action == "push" then
    return exec_push(args)
  elseif action == "apply" then
    return exec_apply_or_pop(args, "apply")
  elseif action == "pop" then
    return exec_apply_or_pop(args, "pop")
  elseif action == "drop" then
    return exec_drop(args)
  end

  return "ArgError: unknown action"
end

local name = "git.stash"

local schema = {
  type = "function",
  ["function"] = {
    name = "git.stash",
    description = "Git stash operations. Prefer action=list then action=show to read stash entry diffs. Index defaults to 0 (stash@{0}).",
    parameters = {
      type = "object",
      properties = {
        action = {
          type = "string",
          description = "list | show | push | apply | pop | drop",
          enum = { "list", "show", "push", "apply", "pop", "drop" },
        },
        index = {
          type = "number",
          description = "Stash index (0 = newest). Used by show/apply/pop/drop. Default 0.",
        },
        path = {
          type = "string",
          description = "Optional path to scope show/push.",
        },
        message = {
          type = "string",
          description = "Optional message for push.",
        },
        include_untracked = {
          type = "boolean",
          description = "If true, push includes untracked files (-u).",
        },
        patch = {
          type = "boolean",
          description = "For show: include full patch (default true). Set false for --stat-like summary only.",
        },
        offset = {
          type = "number",
          description = "For show: 0-based line offset into patch output.",
        },
        limit = {
          type = "number",
          description = "For list: max entries (default 20). For show: max lines (default 200).",
        },
        max_bytes = {
          type = "number",
          description = "Hard cap on returned bytes (show).",
        },
      },
      required = { "action" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
