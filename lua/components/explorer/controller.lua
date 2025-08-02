local M = {}
M.__index = M

function M.new(opts)

  local self = setmetatable({ di = { providers = {}, instances = {} }}, M)

  local base_path = opts.base_path
  local layout = opts.layout or "flat"

  local model = require("components.explorer.model").new(base_path)
  local view = require("components.explorer.view").new()

  local group = nil
  local window = nil

  local function render()
    local tree = model.get_tree()
    view.render(tree)
  end

  function self.render()
    render()
  end

  function self.show()
    if window then
      vim.api.nvim_set_current_win(window)
      return
    end

    view.show()

    window = self.get_window()

    group = vim.api.nvim_create_augroup(("explorer_%d"):format(window), { clear = true })

    vim.api.nvim_create_autocmd("WinClosed", {
      group = group,
      pattern = tostring(window),
      once = true,
      callback = self.close
    })
  end

  function self.close()
    if window then
      if vim.api.nvim_win_is_valid(window) then
        vim.api.nvim_win_close(window, true)
      end
      window= nil
    end
    if group then
      pcall(vim.api.nvim_del_augroup_by_id, group)
      group = nil
    end
  end

  function self.get_buffer()
    return view.get_buffer()
  end

  function self.get_window()
    return view.get_window()
  end

  function self.find_file(path)
    model.expand_until_path(path)
    render()
    local node = model.find_node_by_path(path)
    view.hover_node(node)
  end

  local function using_hovered_node(callback)
    local node = view.get_hovered_node()
    if not node then
      vim.print("explorer: failed to parse selected node")
      return
    end
    callback(node)
  end

  function self.using_hovered_node(callback)
    return using_hovered_node(callback)
  end

  local function refresh()
    using_hovered_node(function(node)
      model.expand_node(node.parent)
      render()
    end)
  end

  function self.refresh()
    refresh()
  end

  local function enter_node(node)
      model.enter_node(node)
      render()
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
    using_hovered_node(function(node)
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
    end)
  end

  -- Set keymaps
  local view_buffer = view.get_buffer()

  vim.keymap.set('n', '<CR>', on_press_enter, { buffer = view_buffer })
  vim.keymap.set('n', 'r',    refresh,        { buffer = view_buffer })

  require("components.explorer.actions.create-file").new(model, view, self)
  require("components.explorer.actions.delete-file").new(model, view, self)
  require("components.explorer.actions.locate-file").new(model, view, self)
  require("components.explorer.actions.move-file").new(model, view, self)

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
