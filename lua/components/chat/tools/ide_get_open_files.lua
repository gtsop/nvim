local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  args = args or {}
  local limit = shared.tonumber_arg(args.limit, 30)
  local paths = {}
  local seen = {}

  local function add_path(p)
    if not p or p == "" or not shared.is_under_project(p) then
      return
    end
    local rel = shared.relativize(p)
    if not seen[rel] then
      table.insert(paths, rel)
      seen[rel] = true
    end
  end

  if ide and ide.get_edited_files then
    for _, p in ipairs(ide.get_edited_files()) do
      add_path(p)
    end
  end

  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local path = buf.name
    if path and path ~= "" and vim.bo[buf.bufnr].buftype == "" then
      add_path(path)
    end
  end

  local slice, total, remaining = shared.paginate(paths, 0, limit)
  if total == 0 then
    return "(no open project files)"
  end
  local body = table.concat(slice, "\n")
  if remaining > 0 then
    body = body .. string.format("\n... truncated (%d more)", remaining)
  end
  return body
end

local name = "ide.get_open_files"

local schema = {
  type = "function",
  ["function"] = {
    name = "ide.get_open_files",
    description = "List recently edited / open project file buffers (compact relative paths).",
    parameters = {
      type = "object",
      properties = {
        limit = {
          type = "number",
          description = "Max paths (default 30).",
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
