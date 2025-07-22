local assert = require("luassert")

local directory_view = require("views.directory")

describe("directory view", function()
  it("renders a directory", function()
    local lines = directory_view.render({
      { "directory-a", "directory" }
    })

    assert.are.same({
      "directory-a/"
    }, lines)
  end)

  it("renders a file", function()
    local lines = directory_view.render({
      { "file-a", "file" }
    })

    assert.are.same({
      "file-a"
    }, lines)
  end)

  it("renders both directories and files", function()
    local lines = directory_view.render({
      { "directory-a", "directory" },
      { "file-a", "file" }
    })

    assert.are.same({
      "directory-a/",
      "file-a"
    }, lines)
  end)

  it("renders nested views", function()
    local lines = directory_view.render({
      { "directory-a", "directory" },
      { "directory-a/directory-b", "directory" },
      { "directory-a/directory-b/file-b", "file" },
      { "directory-a/file-a", "file" },
      { "file", "file" }
    })

    assert.are.same({
      "directory-a/",
      "  directory-b/",
      "    file-b",
      "  file-a",
      "file"
    }, lines)
  end)
end)
