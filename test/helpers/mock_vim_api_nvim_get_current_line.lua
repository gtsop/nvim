local stub = require("luassert.stub")

local function mock_vim_api_nvim_get_current_line(line, before_each, after_each)
	local get_line_stube

	before_each(function()
		get_line_stube = stub(vim.api, "nvim_get_current_line", function()
			return line
		end)
	end)

	after_each(function()
		get_line_stube:revert()
	end)
end

return mock_vim_api_nvim_get_current_line
