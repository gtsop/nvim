local M = {}
M.__index = M

local list_ignore = { ".git", "node_modules", "build" }

local function list_dir_contents(path, opts)

    if path:sub(-1) == "/" then
      path = path.sub(1, -2)
    end

    opts = opts or { recurse = false, rootDir = nil }

    if opts.recurse and not opts.rootDir then
      opts.rootDir = path
    end

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

      table.insert(contents, { path = path .. "/" .. name, name = name, type = typ, is_dir = (typ == "directory") })
      if typ == "directory" and opts.recurse and not table.contains(list_ignore, name) then
        local inner_contents = list_dir_contents(path .. "/" .. name, opts)
        for _, item in ipairs(inner_contents) do
          local prefix = "";
          if path == opts.rootDir then
            prefix = name .. "/"
          else
            prefix = path .. "/" .. name .. "/"
          end
          table.insert(contents, { path = path .. "/" .. name, name = name, type = typ, is_dir = (typ == "directory") })
        end
      end

    end

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
      sub_tree = tree
    end

    for _, node in ipairs(tree) do

      if node.path == node_path then
        return node
      end

      if node.tree then
        return self.find_node_by_path(node_path, node.tree)
      end
    end

    return nil
  end

  function self.scan()
    tree = list_dir_contents(path)
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
    node.tree = list_dir_contents(node.path)
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
