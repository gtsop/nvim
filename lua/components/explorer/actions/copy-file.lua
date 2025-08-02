local M = {}

function M.new(_, _, c)
  local self = setmetatable({}, M)

  function c.copy_file()
    c.using_hovered_node(function(node)
      c:service('ide').copy_file(node.path, c.refresh_dir)
    end)
  end

  return self
end

return M
