local assert = require("luassert")
local spy = require("luassert.spy")
local mock_vim_api_nvim_create_buf = require("test.helpers.mock_vim_api_nvim_create_buf")
local mock_vim_api_nvim_win_get_cursor = require("test.helpers.mock_vim_api_nvim_win_get_cursor")

local View = require("components.explorer.view")

local Panel = require("utils.ui.panel_v2")
local panel = Panel:new()

describe("Explorer View", function()
  local fake_buffer = 1
  mock_vim_api_nvim_create_buf(fake_buffer, before_each, after_each)
  mock_vim_api_nvim_win_get_cursor(2, 0, before_each, after_each)

  it("instanciates", function()
    local view = View.new({ panel = panel })

    assert.is_table(view)
  end)

  test("'render' prints a directory on the buffer", function()
    local s = spy.on(vim.api, "nvim_buf_set_lines")

    local view = View.new({ panel = panel })

    local model = {
      path = "/root",
      name = "/root",
      type = "directory",
      is_dir = true,
      tree = {
        { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true },
      },
    }

    view.render(model)

    assert.spy(s).was_called_with(fake_buffer, 0, -1, false, {
      "⮞ dir-1/",
    })
  end)

  test("'render' prints a file on the buffer", function()
    local s = spy.on(vim.api, "nvim_buf_set_lines")

    local view = View.new({ panel = panel })

    local model = {
      path = "/root",
      name = "/root",
      type = "directory",
      is_dir = true,
      tree = {
        { path = "/root/file-1", name = "file-1", type = "file", is_dir = false },
      },
    }

    view.render(model)

    assert.spy(s).was_called_with(fake_buffer, 0, -1, false, {
      "  file-1",
    })
  end)

  test("'render' prints a directory and a file on the buffer", function()
    local s = spy.on(vim.api, "nvim_buf_set_lines")

    local view = View.new({ panel = panel })

    local model = {
      path = "/root",
      name = "/root",
      type = "directory",
      is_dir = true,
      tree = {
        { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true },
        { path = "/root/file-1", name = "file-1", type = "file", is_dir = false },
      },
    }

    view.render(model)

    assert.spy(s).was_called_with(fake_buffer, 0, -1, false, {
      "⮞ dir-1/",
      "  file-1",
    })
  end)

  test("'render' prints a nested view", function()
    local s = spy.on(vim.api, "nvim_buf_set_lines")

    local view = View.new({ panel = panel })

    local model = {
      path = "/root",
      name = "/root",
      type = "directory",
      is_dir = true,
      tree = {
        {
          path = "/root/dir-1",
          name = "dir-1",
          type = "directory",
          is_dir = true,
          tree = {
            { path = "/root/dir-1/file-2", name = "file-2", type = "file", is_dir = false },
          },
        },
        { path = "/root/file-1", name = "file-1", type = "file", is_dir = false },
      },
    }

    view.render(model)

    assert.spy(s).was_called_with(fake_buffer, 0, -1, false, {
      "⮟ dir-1/",
      "    file-2",
      "  file-1",
    })
  end)

  describe("get_hovered_node", function()
    it("returns the model node that is currently being hovered by the UI", function()
      local view = View.new({ panel = panel })

      local model = {
        path = "/root",
        name = "/root",
        type = "directory",
        is_dir = true,
        tree = {
          { path = "/root/dir-1", name = "dir-1", type = "directory", is_dir = true },
          { path = "/root/dir-2", name = "dir-2", type = "directory", is_dir = true },
          { path = "/root/dir-3", name = "dir-3", type = "directory", is_dir = true },
        },
      }

      view.render(model)

      assert.are.equal(model.tree[2], view.get_hovered_node())
    end)

    it("returns the root node if there are currently no children nodes", function()
      local view = View.new({ panel = panel })

      local model = {
        path = "/root",
        name = "/root",
        type = "directory",
        is_dir = true,
      }

      view.render(model)

      assert.are.equal(view.get_hovered_node(), model)
    end)
  end)

  it("works in nested trees", function()
    local view = View.new({ panel = panel })

    local model = {
      path = "/root",
      name = "/root",
      type = "directory",
      is_dir = true,
      tree = {
        {
          path = "/root/dir-1",
          name = "dir-1",
          type = "directory",
          is_dir = true,
          tree = {
            { path = "/root/dir-2", name = "dir-2", type = "directory", is_dir = true },
          },
        },
        { path = "/root/dir-3", name = "dir-3", type = "directory", is_dir = true },
      },
    }

    view.render(model)

    assert.are.equal(view.get_hovered_node(), model.tree[1].tree[1])
  end)
end)
