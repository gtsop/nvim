local M = {}

function M.new(_, view, controller)
  local self = setmetatable({}, M)

  function self.move_file()
    controller.using_hovered_node(function(node)
      controller:service('ide').move_file(node.path, controller.refresh)
    end)
  end

  vim.keymap.set('n', 'd', self.move_file, { buffer = view.get_buffer() })

  return self
end

return M
