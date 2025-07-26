local M = {}
M.__index = M

function M.new(opts)

  local self = setmetatable({ di = { providers = {}, instances = {} }}, M)

  local base_path = opts.base_path
  local layout = opts.layout or "flat"

  local model = require("components.explorer.model").new(base_path)
  local view = require("components.explorer.view").new()


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
    local tree = model.get_tree()
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

  local function collapse_node(node)
    model.collapse_node(node)
    render()
  end

  local function expand_node(node)
    model.expand_node(node)
    render()
  end

  local function on_press_enter()
    local node = view.get_hovered_node()

    if not node then
      vim.print("explorer: failed to parse selected node")
      return
    end

    if node.is_dir then
      if layout == "flat" then
        enter_node(node)
      elseif layout == "nest" then
        if node.tree then
          collapse_node(node)
        else
          expand_node(node)
        end
      end
    else
      edit_node(node)
    end
  end

  local function create_file()
    local node = view.get_hovered_node()

    if not node then
      vim.print("explorer: failed to parse selected node")
      return
    end

    self:service('ide').create_file(node.path)
  end

  -- Set keymaps
  local view_buffer = view.get_buffer()
  vim.keymap.set('n', '<CR>', on_press_enter, { buffer = view_buffer })
  vim.keymap.set('n', '0', go_to_root, { buffer = view_buffer })
  vim.keymap.set('n', '-', go_dir_up, { buffer = view_buffer })
  vim.keymap.set('n', 'a', create_file, { buffer = view_buffer })

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
