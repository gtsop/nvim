-- In-memory todo store shared by agent.todo_write / agent.todo_read.
-- Not a tool itself.
local M = {
  _enabled = false,
  items = {},
}

function M.write(todos)
  M.items = {}
  if type(todos) ~= "table" then
    return false, "ArgError: 'todos' must be a list"
  end
  for _, t in ipairs(todos) do
    if type(t) == "table" then
      table.insert(M.items, {
        id = tostring(t.id or (#M.items + 1)),
        content = tostring(t.content or ""),
        status = tostring(t.status or "pending"),
      })
    end
  end
  return true, nil
end

function M.read()
  if #M.items == 0 then
    return "(no todos)"
  end
  local lines = {}
  for _, t in ipairs(M.items) do
    table.insert(lines, string.format("[%s] %s: %s", t.status, t.id, t.content))
  end
  return table.concat(lines, "\n")
end

return M
