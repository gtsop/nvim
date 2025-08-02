local M = {}

function M.new(_, _, c)
  local self = setmetatable({}, M)

  function c.move_file()
    c.using_hovered_node(function(node)
      c:service('ide').move_file(node.path, c.refresh)
    end)
  end

  return self
end

return M
