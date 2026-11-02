local shared = require("components.chat.tools._shared")

local function build_rg_argv(pattern, search_path, args)
  local argv = {
    "rg",
    "--line-number",
    "--with-filename",
    "--no-heading",
    "--color",
    "never",
    "--max-columns",
    "200",
  }
  if not shared.truthy(args.case_sensitive) then
    table.insert(argv, "-i")
  end
  local context = shared.tonumber_arg(args.context, 0)
  if context > 0 then
    table.insert(argv, "-C")
    table.insert(argv, tostring(math.min(context, 2)))
  end
  if args.glob and args.glob ~= "" then
    table.insert(argv, "--glob")
    table.insert(argv, tostring(args.glob))
  end
  for _, d in ipairs(shared.IGNORE_DIRS) do
    table.insert(argv, "--glob")
    table.insert(argv, "!" .. d)
  end
  table.insert(argv, "--")
  table.insert(argv, tostring(pattern))
  table.insert(argv, search_path)
  return argv
end

local function build_grep_argv(pattern, search_path, args)
  local argv = { "grep", "-R", "-n", "-H", "--color=never" }
  if not shared.truthy(args.case_sensitive) then
    table.insert(argv, "-i")
  end
  for _, d in ipairs(shared.IGNORE_DIRS) do
    table.insert(argv, "--exclude-dir")
    table.insert(argv, d)
  end
  if args.glob and args.glob ~= "" then
    table.insert(argv, "--include")
    table.insert(argv, tostring(args.glob))
  end
  table.insert(argv, "-e")
  table.insert(argv, tostring(pattern))
  table.insert(argv, search_path)
  return argv
end

local function exec(args, ide)
  args = args or {}
  local pattern = args.pattern
  if not pattern or pattern == "" then
    return "ArgError: 'pattern' is required"
  end

  local search_path = shared.project_root()
  local path_args = { search_path }
  if args.path and args.path ~= "" then
    local resolved, err = shared.resolve_project_path(args.path)
    if err then
      return err
    end
    search_path = resolved
    path_args = { search_path }
  end

  local argv
  if shared.has_executable("rg") then
    argv = build_rg_argv(pattern, search_path, args)
  elseif shared.has_executable("grep") then
    argv = build_grep_argv(pattern, search_path, args)
  else
    return "Error: neither rg nor grep is available"
  end

  local result, run_err = shared.run_argv(argv, {
    cwd = shared.project_root(),
    path_args = path_args,
  })
  if run_err then
    return run_err
  end

  -- rg/grep: 0 = matches, 1 = no matches, >=2 = error
  if result.code > 1 then
    return "Error: search failed: " .. shared.truncate_text(result.stderr ~= "" and result.stderr or result.stdout, 2000)
  end

  local lines = {}
  for line in (result.stdout or ""):gmatch("[^\n]+") do
    local file, rest = line:match("^([^:]+):(.*)$")
    if file then
      table.insert(lines, shared.relativize(file) .. ":" .. rest)
    else
      table.insert(lines, line)
    end
  end

  local offset = shared.tonumber_arg(args.offset, 0)
  local limit = shared.tonumber_arg(args.limit, shared.DEFAULTS.grep_limit)
  local slice, total, remaining = shared.paginate(lines, offset, limit)

  if total == 0 then
    return "(no matches)"
  end

  local body = table.concat(slice, "\n")
  if remaining > 0 then
    body = body
      .. string.format("\n... truncated (%d more of %d total; use offset/limit)", remaining, total)
  end
  return shared.truncate_text(body, args.max_bytes)
end

local name = "project.grep"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.grep",
    description = "Search project text (rg or grep). Returns compact path:line:text rows. Always use limit; refine with path/glob.",
    parameters = {
      type = "object",
      properties = {
        pattern = {
          type = "string",
          description = "Search pattern (regex).",
        },
        path = {
          type = "string",
          description = "Subpath to search within (file or directory).",
        },
        glob = {
          type = "string",
          description = "File glob filter (e.g. '*.lua').",
        },
        case_sensitive = {
          type = "boolean",
          description = "Case-sensitive search (default false).",
        },
        context = {
          type = "number",
          description = "Context lines around match when using rg (0-2, default 0).",
        },
        offset = {
          type = "number",
          description = "0-based result offset (default 0).",
        },
        limit = {
          type = "number",
          description = "Max match lines (default 50).",
        },
        max_bytes = {
          type = "number",
          description = "Hard cap on returned bytes.",
        },
      },
      required = { "pattern" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
