local M = {}
M.__index = M

function M.new()
  local self = setmetatable({}, M)

  function self.open()

  end

  return self
end

return M
