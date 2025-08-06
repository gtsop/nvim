local M = {}

function M.create(m, _, c)
  return function()
    c.using_hovered_node(function(node)
      if node.tree then
        m.collapse_node(node)
      else
        m.expand_node(node)
      end
      c.render()
    end)
  end
end

return M
