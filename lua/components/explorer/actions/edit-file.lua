local M = {}

function M.new(_, _, c)
  local self = setmetatable({}, M)

  function c.edit_file()
    c.using_hovered_node(function(node)
      if not node.is_dir then
        c:service('ide').edit(node.path)
      end
    end)
  end

  return self
end

return M
