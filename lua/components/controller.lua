local M = {}
M.__index = M

function M.new()
  local self = setmetatable({}, M)

  -- Register actions

  -- Register keymaps

  return self
end

return M
