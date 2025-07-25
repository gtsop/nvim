local stub = require('luassert.stub')

local function mock_vim_api_nvim_create_buf(buffer, before_each, after_each)
  local create_buf_stub

  before_each(function()
    create_buf_stub = stub(vim.api, 'nvim_create_buf', function() return buffer end)
  end)

  after_each(function()
    create_buf_stub:revert()
  end)
end

return mock_vim_api_nvim_create_buf

