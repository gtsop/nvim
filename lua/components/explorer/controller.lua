local M = {}
M.__index = M

function M.new(base_path)
  local self = setmetatable({ di = { providers = {}, instances = {} }}, M)

  local model = require("components.explorer.model").new(base_path)
  local view = require("components.explorer.view").new()

  local tree = nil

  function self.show()
    view.show()
  end

  function self.get_buffer()
    return view.get_buffer()
  end

  function self.get_window()
    return view.get_window()
  end

  local function render()
    tree = model.get_tree()
    view.render(tree)
  end

  local function enter_node(node)
      model.enter_node(node)
      render()
  end

  local function go_to_root()
    model.reset()
    render()
  end

  local function go_dir_up()
    vim.print("not implemented")
  end

  local function edit_node(node)
      self:service('ide').edit(node.path)
  end

  local function on_press_enter()
    local node = view.get_hovered_node(tree)
    if node.is_dir then
      enter_node(node)
    else
      edit_node(node)
    end
  end

  local function on_press_zero()
    go_to_root()
  end

  local function on_press_minus()
    go_dir_up()
  end

  -- Set keymaps
  vim.keymap.set('n', '<CR>', on_press_enter)
  vim.keymap.set('n', '0', on_press_zero)
  vim.keymap.set('n', '-', on_press_minus)

  render()

  return self
end

function M:register(name, provider)
  self.di.providers[name] = provider
end

function M:service(name)
  if not self.di.instances[name] then
    self.di.instances[name] = self.di.providers[name](self)
  end
  return self.di.instances[name]
end

return M
