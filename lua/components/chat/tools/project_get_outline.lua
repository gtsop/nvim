local shared = require("components.chat.tools._shared")

-- Lightweight regex outline for common languages (no full file dump).
local PATTERNS = {
  -- Lua
  { "^%s*function%s+([%w_%.%:]+)%s*%(", "function" },
  { "^%s*local%s+function%s+([%w_]+)%s*%(", "function" },
  { "^%s*([%w_]+)%.([%w_]+)%s*=%s*function%s*%(", "method" },
  -- JS/TS
  { "^%s*(?:export%s+)?(?:async%s+)?function%s+([%w_]+)", "function" },
  { "^%s*(?:export%s+)?(?:default%s+)?class%s+([%w_]+)", "class" },
  { "^%s*(?:export%s+)?(?:const|let|var)%s+([%w_]+)%s*=%s*(?:async%s+)?%(", "function" },
  { "^%s*(?:export%s+)?(?:const|let|var)%s+([%w_]+)%s*=%s*(?:async%s+)?function", "function" },
  { "^%s*(?:public|private|protected)?%s*(?:async%s+)?([%w_]+)%s*%([^)]*%)%s*[%{:]", "method" },
  -- Python
  { "^%s*def%s+([%w_]+)%s*%(", "function" },
  { "^%s*class%s+([%w_]+)", "class" },
  -- Go
  { "^func%s+%(?[^)]*%)?%s*([%w_]+)%s*%(", "function" },
  { "^type%s+([%w_]+)%s+struct", "type" },
  -- Rust
  { "^%s*(?:pub%s+)?fn%s+([%w_]+)", "function" },
  { "^%s*(?:pub%s+)?struct%s+([%w_]+)", "struct" },
  { "^%s*(?:pub%s+)?enum%s+([%w_]+)", "enum" },
  -- Generic headings / exports
  { "^%s*exports%.([%w_]+)", "export" },
}

local function exec(args, ide)
  args = args or {}
  local path, err = shared.resolve_project_path(args.path or "")
  if err then
    return err
  end
  if vim.fn.filereadable(path) ~= 1 then
    return "ArgError: 'path' is not a readable file"
  end

  local lines, read_err = shared.read_lines(path)
  if read_err then
    return read_err
  end

  local max_symbols = shared.tonumber_arg(args.max_symbols, shared.DEFAULTS.outline_max)
  local symbols = {}

  for i, line in ipairs(lines) do
    for _, pat in ipairs(PATTERNS) do
      local a, b = line:match(pat[1])
      if a then
        local name = b and (a .. "." .. b) or a
        table.insert(symbols, string.format("%d|%s %s", i, pat[2], name))
        break
      end
    end
    if #symbols >= max_symbols then
      break
    end
  end

  if #symbols == 0 then
    return string.format("(no symbols found in %s)", shared.relativize(path))
  end

  local body = table.concat(symbols, "\n")
  if #symbols >= max_symbols then
    body = body .. string.format("\n... truncated at %d symbols", max_symbols)
  end
  return body
end

local name = "project.get_outline"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.get_outline",
    description = "Return a compact symbol outline (functions/classes) for a file without loading full contents.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Project file path.",
        },
        max_symbols = {
          type = "number",
          description = "Max symbols to return (default 80).",
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
