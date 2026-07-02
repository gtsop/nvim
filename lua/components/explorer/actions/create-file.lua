local M = {}

function M.create(_, _, c)
  return function()
    c.using_hovered_node(function(node)
      c.ide.create_file(node.path, function(created_file)
        c.refresh_dir()
        c.find_file({ path = created_file })
        c.ide.edit(created_file)
      end)
    end)
  end
end

return M
