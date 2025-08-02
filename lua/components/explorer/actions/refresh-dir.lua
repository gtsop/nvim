local M = {}

function M.new(m, _, c)
  local self = setmetatable({}, M)

  function c.refresh_dir()
    c.using_hovered_node(function(node)
      m.expand_node(node.parent)
      c.render()
    end)
  end

  return self
end

return M
