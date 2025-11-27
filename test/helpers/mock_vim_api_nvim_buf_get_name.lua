local stub = require("luassert.stub")

local function mock_vim_api_nvim_buf_get_name(name, before_each, after_each)
  local get_name_stub

  before_each(function()
    get_name_stub = stub(vim.api, "nvim_buf_get_name", function()
      return name
    end)
  end)

  after_each(function()
    get_name_stub:revert()
  end)
end

return mock_vim_api_nvim_buf_get_name
