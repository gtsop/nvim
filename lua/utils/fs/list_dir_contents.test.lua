local assert = require("luassert")
local stub = require("luassert.stub")

local list_dir_contents = require("utils.fs.list_dir_contents")

describe("list_dir_contents", function()

  local fs_next

  before_each(function()
    local root_contents = {
      { nil, nil },
      { "file-a", "file" },
      { "directory-a", "directory" },
    }
    local dir_contents = {
      { nil, nil },
      { "file-b", "file" },
      { "directory-b", "directory" },
    }

    fs_next = stub(vim.uv, 'fs_scandir_next', function(handle)
      local item
      if handle == "root" then
        item = table.remove(root_contents)
      elseif handle == "root/directory-a" then
        item = table.remove(dir_contents)
      elseif handle == "root/directory-a/directory-b" then
        item = { nil, nil }
      end
      return item[1], item[2]
    end)
  end)

  after_each(function()
    fs_next:revert()
  end)

  it("exists", function()
    assert.is_function(list_dir_contents)
  end)

  it("returns a list with the contents of a directory", function()

    local dir_contents = list_dir_contents("root")

    assert.are.same({
      { "directory-a", "directory" },
      { "file-a", "file" }
    }, dir_contents)

  end)

  it("recurses the directory tree", function()

    local dir_contents = list_dir_contents("root", { recurse = true })

    assert.are.same({
      { "directory-a", "directory" },
      { "directory-a/directory-b", "directory" },
      { "directory-a/file-b", "file" },
      { "file-a", "file" }
    }, dir_contents)

  end)

end)
