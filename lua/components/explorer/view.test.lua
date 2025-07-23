local assert = require("luassert")
local spy = require("luassert.spy")

local View = require("components.explorer.view")

test = it

describe("Explorer View", function()
  it("instanciates", function()
    local view = View.new()

    assert.is_table(view)
  end)

  test("'render' prints a directory on the buffer", function()
    local s = spy.on(vim.api, "nvim_buf_set_lines")

    local buffer = 1
    local view = View.new(buffer)

    local model_tree = {
      { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true },
    }

    view.render(model_tree)

    assert.spy(s).was_called_with(buffer, 0, -1, false, {
      "dir-1/"
    })
  end)

  test("'render' prints a file on the buffer", function()
    local s = spy.on(vim.api, "nvim_buf_set_lines")

    local buffer = 1
    local view = View.new(buffer)

    local model_tree = {
      { path = "/root/file-1", name = "file-1", type = "file", is_dir = false },
    }

    view.render(model_tree)

    assert.spy(s).was_called_with(buffer, 0, -1, false, {
      "file-1"
    })
  end)

  test("'render' prints a directory and a file on the buffer", function()
    local s = spy.on(vim.api, "nvim_buf_set_lines")

    local buffer = 1
    local view = View.new(buffer)

    local model_tree = {
      { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true },
      { path = "/root/file-1", name = "file-1", type = "file", is_dir = false }
    }

    view.render(model_tree)

    assert.spy(s).was_called_with(buffer, 0, -1, false, {
      "dir-1/",
      "file-1"
    })
  end)
end)
