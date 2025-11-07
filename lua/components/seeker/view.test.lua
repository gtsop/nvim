local assert = require("luassert")
local spy = require("luassert.spy")
local mock_vim_api_nvim_create_buf = require("test.helpers.mock_vim_api_nvim_create_buf")
-- local mock_vim_api_nvim_win_get_cursor = require("test.helpers.mock_vim_api_nvim_win_get_cursor")

local View = require("components.seeker.view")

describe("Seeker View", function()
	local fake_buffer = 1
	mock_vim_api_nvim_create_buf(fake_buffer, before_each, after_each)
	--	mock_vim_api_nvim_win_get_cursor(2, 0, before_each, after_each)

	it("instanciates", function()
		local view = View.new()

		assert.is_table(view)
	end)

	test("it prints the file name followed by the line number and line text", function()
		local s = spy.on(vim.api, "nvim_buf_set_lines")

		local view = View.new()

		local model = {
			{
				file = "/root/index.js",
				line = 1,
				text = "  foo",
			},
			{
				file = "/root/lib.js",
				line = 30,
				text = "foobar",
			},
		}

		view.render(model)

		assert.spy(s).was_called_with(fake_buffer, 0, -1, false, {
			"/root/index.js",
			"1:  foo",
			"/root/lib.js",
			"30:foobar",
		})
	end)
end)
