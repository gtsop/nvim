local assert = require("luassert")
local mock_vim_uv = require("test.helpers.mock_vim_uv")

local Model = require("components.explorer.model")

local test = it

describe("Explorer Model", function()
  mock_vim_uv({
    ["/root"] = {
      { "dir-1", "directory" },
      { "file-1", "file" },
      { nil, nil }
    },
    ["/root/dir-1"] = {
      { "dir-2", "directory" },
      { "file-2", "file" },
      { nil, nil }
    },
    ["/root/dir-1/dir-2"] = {
      { "file-3", "file" },
      { nil, nil }
    },
    ["/unsorted"] = {
      { "file-2", "file" },
      { "dir-2", "directory" },
      { "dir-1", "directory" },
      { "file-1", "file" },
    }
  }, before_each, after_each)

  it("instanciates", function()
    local model = Model.new()

    assert.is_table(model)
  end)

  test("'scan' sorts contents by directory and by name", function()
    local model = Model.new("/unsorted")

    local root = { path = "/unsorted", name = "/unsorted", type = "directory", is_dir = true }
    root.tree = {
      { path = "/unsorted/dir-1", name = "dir-1", type = "directory", is_dir = true, parent = root },
      { path = "/unsorted/dir-2", name = "dir-2", type = "directory", is_dir = true, parent = root },
      { path = "/unsorted/file-1", name = "file-1", type = "file", is_dir = false, parent = root },
      { path = "/unsorted/file-2", name = "file-2", type = "file", is_dir = false, parent = root }
    }

    assert.are.same(root, model.get_tree())
  end)

  test("'get_tree' returns the contents of the directory", function()
    local model = Model.new("/root")

    local root = { path = "/root", name = "/root", type = "directory", is_dir = true }
    root.tree = {
      { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true, parent = root },
      { path = "/root/file-1", name = "file-1", type = "file", is_dir = false, parent = root },
    }

    assert.are.same(root, model.get_tree())
  end)

  test("'expand_node' expands a specified node", function()
    local model = Model.new("/root")

    model.scan()
    local node = model.find_node_by_path("/root/dir-1")
    model.expand_node(node)

    local root = { path = "/root", name = "/root", type = "directory", is_dir = true }
    root.tree = {
      { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true, parent = root },
      { path = "/root/file-1", name = "file-1", type = "file", is_dir = false, parent = root },
    }
    root.tree[1].tree = {
      { path = "/root/dir-1/dir-2", name = "dir-2", type = "directory", is_dir = true, parent = root.tree[1] },
      { path = "/root/dir-1/file-2", name = "file-2", type = "file", is_dir = false, parent = root.tree[1] }
    }

    assert.are.same(root, model.get_tree())
  end)

  test("'collapse_node' collapses a specified node", function()
    local model = Model.new("/root")

    model.scan()

    local node = model.find_node_by_path("/root/dir-1")
    model.expand_node(node)
    model.collapse_node(node)

    local root = { path = "/root", name = "/root", type = "directory", is_dir = true }
    root.tree = {
      { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true, parent = root },
      { path = "/root/file-1", name = "file-1", type = "file", is_dir = false, parent = root },
    }

    assert.are.same(root, model.get_tree())
  end)

  test("'expand_until_path' expands nodes until it reaches the path", function()

    local model = Model.new("/root")

    model.scan()

    model.expand_until_path("/root/dir-1/dir-2/file-3")

    local root = { path = "/root", name = "/root", type = "directory", is_dir = true }
    root.tree = {
      { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true, parent = root },
      { path = "/root/file-1", name = "file-1", type = "file", is_dir = false, parent = root },
    }
    root.tree[1].tree = {
      { path = "/root/dir-1/dir-2", name = "dir-2", type = "directory", is_dir = true, parent = root.tree[1] },
      { path = "/root/dir-1/file-2", name = "file-2", type = "file", is_dir = false, parent = root.tree[1] }
    }
    root.tree[1].tree[1].tree = {
      { path = "/root/dir-1/dir-2/file-3", name = "file-3", type = "file", is_dir = false, parent = root.tree[1].tree[1] },
    }

    assert.are.same(root, model.get_tree())

  end)
end)
