local stub = require("luassert.stub")

local function mock_vim_api_nvim_buf_get_lines(lines, before_each, after_each)
  local get_lines_stub

  before_each(function()
    get_lines_stub = stub(vim.api, "nvim_buf_get_lines", function()
      return lines
    end)
  end)

  after_each(function()
    get_lines_stub:revert()
  end)
end

return mock_vim_api_nvim_buf_get_lines
