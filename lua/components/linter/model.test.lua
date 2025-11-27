local assert = require("luassert")
local LinterModel = require("components.linter.model")
local mock_buf_get_lines = require("test.helpers.mock_vim_api_nvim_buf_get_lines")
local mock_buf_get_name = require("test.helpers.mock_vim_api_nvim_buf_get_name")

describe("LinterModel", function()
  mock_buf_get_lines({ "line1", "line2" }, before_each, after_each)
  mock_buf_get_name("/root/file.txt", before_each, after_each)

  it("instanciates", function()
    local model = LinterModel.new()

    assert.is_table(model)
  end)

  test("get_lines() returns the lines of code", function()
    local model = LinterModel.new()

    assert.are.same(model.get_lines(), { "line1", "line2" })
  end)

  test("get_file_path() returns the path of the file", function()
    local model = LinterModel.new()

    assert.are.same(model.get_file_path(), "/root/file.txt")
  end)
end)
