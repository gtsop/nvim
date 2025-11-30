local M = {}

function M.create(_, _, c)
  return function()
    c.using_hovered_node(function(node)
      c.ide.copy_file(node.path, c.refresh_dir)
    end)
  end
end

return M
