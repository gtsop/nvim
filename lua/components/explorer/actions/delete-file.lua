local M = {}

function M.new(_, view, controller)
  local self = setmetatable({}, M)

  function self.delete_file()
    controller.using_hovered_node(function(node)
      controller:service('ide').delete_file(node.path, controller.refresh)
    end)
  end

  vim.keymap.set('n', 'd', self.delete_file, { buffer = view.get_buffer() })

  return self
end

return M
