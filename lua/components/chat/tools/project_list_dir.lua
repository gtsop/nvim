local shared = require("components.chat.tools._shared")
local list_dir_contents = require("utils.fs.list_dir_contents")

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
      return "ArgError: 'path' must be a directory"
    end
    base = resolved
  end

  local recurse = shared.truthy(args.recurse)
  local contents = list_dir_contents(base, { recurse = recurse, rootDir = base })

  local entries = {}
  for _, item in ipairs(contents) do
    local name, typ = item[1], item[2]
    if not vim.tbl_contains(shared.IGNORE_DIRS, name:match("[^/]+") or name) then
      local marker = typ == "directory" and "/" or ""
      table.insert(entries, name .. marker)
    end
  end

  table.sort(entries)

  local offset = shared.tonumber_arg(args.offset, 0)
  local limit = shared.tonumber_arg(args.limit, shared.DEFAULTS.list_limit)
  local slice, total, remaining = shared.paginate(entries, offset, limit)

  local body = table.concat(slice, "\n")
  if remaining > 0 then
    body = body
      .. string.format("\n... truncated (%d more of %d total; use offset/limit)", remaining, total)
  elseif total == 0 then
    body = "(empty directory)"
  end
  return body
end

local name = "project.list_dir"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.list_dir",
    description = "List a single directory's entries (files and dirs). recurse defaults to false for a compact listing.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Directory path (default: project root).",
        },
        recurse = {
          type = "boolean",
          description = "If true, list recursively (default false).",
        },
        offset = {
          type = "number",
          description = "0-based offset (default 0).",
        },
        limit = {
          type = "number",
          description = "Max entries (default 100).",
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
