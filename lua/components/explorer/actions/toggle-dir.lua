local M = {}

function M.new(m, _, c)
  local self = setmetatable({}, M)

  function c.toggle_dir()
    c.using_hovered_node(function(node)
      if node.tree then
        m.collapse_node(node)
      else
        m.expand_node(node)
      end
      c.render()
    end)
  end

  return self
end

return M
