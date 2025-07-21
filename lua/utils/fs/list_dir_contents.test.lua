local assert = require("luassert")
local stub = require("luassert.stub")

local list_dir_contents = require("utils.fs.list_dir_contents")

describe("list_dir_contents", function()

  local fs_next

  before_each(function()
    local contents = {
      { nil, nil },
      { "file-a", "file" },
      { "directory-a", "directory" },
    }

    fs_next = stub(vim.uv, 'fs_scandir_next', function()
      local item = table.remove(contents)
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

    local dir_contents = list_dir_contents("some/path")

    assert.are.same({
      { "directory-a", "directory" },
      { "file-a", "file" }
    }, dir_contents)

  end)
end)
