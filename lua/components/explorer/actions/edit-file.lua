local M = {}

function M.create(_, _, c)
  return function()
    c.using_hovered_node(function(node)
      if not node.is_dir then
        c.ide.edit(node.path)
      end
    end)
  end
end

return M
