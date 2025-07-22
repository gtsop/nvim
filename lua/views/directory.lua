local M = {}


local function count_char(s, sep)
  local c = 0
  for _ in string.gmatch(s, "([^" .. sep .. "]+)") do
    c = c + 1
  end
  return c
end

local function split_path(full_path)
  local dir, file = full_path:match("^(.*[/\\])([^/\\]+)$")
  dir  = dir  or ""
  file = file or full_path

  local base, ext = file:match("^(.*)%.([^%.]+)$")
  if not base then
    base, ext = file, ""
  end

  return dir, base, ext
end

local function nest(name)
  local dir, base, ext = split_path(name)

  local nests = count_char(dir, "/")

  local ex = ""
  if #ext > 0 then
    ex = "." .. ext
  end

  return string.rep("  ", nests) .. base .. ex
end

function M.render(tree)
  local lines = {}

  for _, item in ipairs(tree) do
    local name = item[1]
    local type = item[2]

    if type == "directory" then
      table.insert(lines, nest(name) .. "/")
    elseif type == "file" then
      table.insert(lines, nest(name))
    end
  end

  return lines

end

return M
