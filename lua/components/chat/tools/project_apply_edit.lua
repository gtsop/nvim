local shared = require("components.chat.tools._shared")

local function read_raw(path)
  local resolved, err = shared.resolve_project_path(path, { must_exist = true })
  if err then
    return nil, err
  end
  if vim.fn.filereadable(resolved) ~= 1 then
    return nil, "ArgError: file does not exist"
  end
  local file, open_err = io.open(resolved, "r")
  if not file then
    return nil, "Error: failed to read: " .. tostring(open_err)
  end
  local content = file:read("*a") or ""
  file:close()
  return content, nil, resolved
end

local function exec(args, ide)
  args = args or {}
  local old_string = args.old_string
  local new_string = args.new_string
  if old_string == nil or old_string == "" then
    return "ArgError: 'old_string' is required and must be non-empty"
  end
  if new_string == nil then
    return "ArgError: 'new_string' is required"
  end

  local content, read_err, path = read_raw(args.path or "")
  if read_err then
    return read_err
  end

  local replace_all = shared.truthy(args.replace_all)

  local count = 0
  local start = 1
  while true do
    local i, j = content:find(old_string, start, true)
    if not i then
      break
    end
    count = count + 1
    start = j + 1
    if not replace_all then
      break
    end
  end

  if count == 0 then
    return "Error: old_string not found in file"
  end
  if count > 1 and not replace_all then
    return string.format(
      "Error: old_string matched %d times; pass replace_all=true or include more surrounding context to uniquely identify the edit",
      count
    )
  end

  local new_content
  if replace_all then
    new_content = content:gsub(vim.pesc(old_string), function()
      return new_string
    end)
  else
    local i, j = content:find(old_string, 1, true)
    new_content = content:sub(1, i - 1) .. new_string .. content:sub(j + 1)
  end

  local _, write_err = shared.write_file(path, new_content)
  if write_err then
    return write_err
  end
  return string.format(
    "Applied edit to %s (%d replacement%s)",
    shared.relativize(path),
    replace_all and count or 1,
    (replace_all and count or 1) == 1 and "" or "s"
  )
end

local name = "project.apply_edit"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.apply_edit",
    description = "Replace a unique old_string with new_string in a file. Prefer this over write_file for small edits. Include enough context in old_string to be unique unless replace_all=true.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Project file path.",
        },
        old_string = {
          type = "string",
          description = "Exact text to find.",
        },
        new_string = {
          type = "string",
          description = "Replacement text.",
        },
        replace_all = {
          type = "boolean",
          description = "Replace every occurrence (default false).",
        },
      },
      required = { "path", "old_string", "new_string" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
