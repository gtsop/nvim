local M = {}
M.__index = M

function M.new(base_path)
  local self = setmetatable({}, M)

  local model = require("components.explorer.model").new(base_path)
  local view = require("components.explorer.view").new()

  local view_buffer = view.get_buffer()

  local tree = model.get_tree()
  view.render(tree)

  function self.show()
    view.show()
  end

  function self.get_buffer()
    return view_buffer
  end

  function self.get_window()
    return view.get_window()
  end

  local function on_enter()

  end

  -- Set keymaps
  vim.keymap.set('n', '<CR>', on_enter)

  return self
end

return M
