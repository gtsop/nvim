local shared = require("components.chat.tools._shared")
local utils = require("utils")

local function exec(args, ide)
  args = args or {}
  local root = shared.project_root()
  local base = root

  if args.path and args.path ~= "" then
    local resolved, err = shared.resolve_project_path(args.path)
    if err then
      return err
    end
    if vim.fn.isdirectory(resolved) == 0 then
      return "ArgError: 'path' must be a directory within the project"
    end
    base = resolved
  end

  local files = utils.list_dir_files(base, true)
  local relative = {}
  for _, f in ipairs(files) do
    table.insert(relative, shared.relativize(f))
  end

  local query = args.query
  local glob = args.glob
  local filtered = {}
  for _, rel in ipairs(relative) do
    local ok = true
    if query and query ~= "" then
      ok = rel:lower():find(query:lower(), 1, true) ~= nil
    end
    if ok and glob and glob ~= "" then
      ok = shared.match_glob(rel, glob) or shared.match_glob(vim.fn.fnamemodify(rel, ":t"), glob)
    end
    if ok then
      table.insert(filtered, rel)
    end
  end

  local offset = shared.tonumber_arg(args.offset, 0)
  local limit = shared.tonumber_arg(args.limit, shared.DEFAULTS.list_limit)
  local slice, total, remaining = shared.paginate(filtered, offset, limit)

  local body = table.concat(slice, "\n")
  if remaining > 0 then
    body = body
      .. string.format("\n... truncated (%d more of %d total; use offset/limit)", remaining, total)
  elseif total == 0 then
    body = "(no files matched)"
  end
  return body
end

local name = "project.list_files"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.list_files",
    description = "List project file paths (relative). Prefer query/glob/path and offset/limit to avoid dumping the whole tree.",
    parameters = {
      type = "object",
      properties = {
        query = {
          type = "string",
          description = "Case-insensitive substring filter on relative paths.",
        },
        glob = {
          type = "string",
          description = "Simple glob filter (e.g. '*.lua', '**/test/**').",
        },
        path = {
          type = "string",
          description = "Subdirectory to list under (project-relative or absolute under project).",
        },
        offset = {
          type = "number",
          description = "0-based offset into results (default 0).",
        },
        limit = {
          type = "number",
          description = "Max paths to return (default 100).",
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
