local stub = require('luassert.stub')

local function mock_vim_api_nvim_win_get_cursor(line, column, before_each, after_each)
  local get_cursor_stub

  before_each(function()
    get_cursor_stub = stub(vim.api, 'nvim_win_get_cursor', function() return { line, column } end)
  end)

  after_each(function()
    get_cursor_stub:revert()
  end)
end

return mock_vim_api_nvim_win_get_cursor
