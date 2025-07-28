local M = {}
M.__index = M

local function list_dir_contents(path, opts)

    if path:sub(-1) == "/" then
      path = path.sub(1, -2)
    end

    opts = opts or { parent = nil }

    local contents = {}

    local handle = vim.uv.fs_scandir(path)
    if not handle then
      return contents
    end

    while true do
      local name, typ = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end

      table.insert(contents, { path = path .. "/" .. name, name = name, type = typ, is_dir = (typ == "directory"), parent = opts.parent })
    end

    table.sort(contents, function(a, b)
      if a.is_dir ~= b.is_dir then
        return a.is_dir
      end

      return a.name < b.name
    end)

    return contents
end

function M.new(path)
  local self = setmetatable({}, M)

  local tree = nil

  function self.find_node_by_path(node_path, sub_tree)
    if not tree then
      return nil
    end

    if not sub_tree then
      sub_tree = tree.tree
    end

    for _, node in ipairs(sub_tree) do

      if node.path == node_path then
        return node
      end

      if node.tree and #node.tree > 0 then
        return self.find_node_by_path(node_path, node.tree)
      end
    end

    return nil
  end

  function self.scan()
    tree = { path = path, name = path, type = "directory", is_dir = true, parent = nil }
    tree.tree = list_dir_contents(path, { parent = tree })
  end

  function self.get_tree()
    if not tree then
      self.scan()
    end

    return tree
  end

  function self.enter_node(node)
    self.expand_node(node)
    tree = node.tree
  end

  function self.expand_node(node)
    node.tree = list_dir_contents(node.path, { parent = node })
  end

  function self.collapse_node(node)
    node.tree = nil
  end

  function self.reset()
    self.scan()
  end

  return self
end

return M
