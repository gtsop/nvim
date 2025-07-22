local M = {}

function M.render(tree)
  local lines = {}

  for _, item in ipairs(tree) do
    local name = item[1]
    local type = item[2]

    if type == "directory" then
      table.insert(lines, name .. "/")
    elseif type == "file" then
      table.insert(lines, name)
    end
  end

  return lines

end

return M
