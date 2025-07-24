local M = {}
M.__index = M

function M.new(base_path, buffer_id)
  local self = setmetatable({}, M)

  local model = require("components.explorer.model").new(base_path)
  local view = require("components.explorer.view").new(buffer_id)

  local tree = model.get_tree()
  view.render(tree)

  return self
end

return M
