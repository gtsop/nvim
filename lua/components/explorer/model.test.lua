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
    }
  }, before_each, after_each)

  it("instanciates", function()
    local model = Model.new()

    assert.is_table(model)
  end)

  test("'get_tree' returns the contents of the directory", function()
    local model = Model.new("/root")

    assert.are.same({
      { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true },
      { path = "/root/file-1", name = "file-1", type = "file", is_dir = false }
    }, model.get_tree())
  end)

  test("'expand_node' expands a specified node", function()
    local model = Model.new("/root")

    model.scan()
    local node = model.find_node_by_path("/root/dir-1")
    model.expand_node(node)

    assert.are.same({
      { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true, tree = {
        { path = "/root/dir-1/dir-2", name = "dir-2", type = "directory", is_dir = true },
        { path = "/root/dir-1/file-2", name = "file-2", type = "file", is_dir = false },
      }},
      { path = "/root/file-1", name = "file-1", type = "file", is_dir = false }
    }, model.get_tree())
  end)

  test("'collapse_node' collapses a specified node", function()
    local model = Model.new("/root")

    model.scan()

    local node = model.find_node_by_path("/root/dir-1")
    model.expand_node(node)
    model.collapse_node(node)

    assert.are.same({
      { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true },
      { path = "/root/file-1", name = "file-1", type = "file", is_dir = false }
    }, model.get_tree())
  end)

end)
