local M = {}

local fs = require("utils.fs")
local path = require("utils.fs.path")

function M.create(_, _, c)
	return function()
		local file = vim.api.nvim_buf_get_name(0)

		local dirname = path.dirname(file)
		local basename = path.basename(file, true)
		local extension = path.extension(file)

		local unit_test_file = ""

		if extension == "lua" then
			unit_test_file = dirname .. "/" .. basename .. ".test.lua"
		elseif extension == "js" then
			unit_test_file = dirname .. "/" .. basename .. ".test.js"
		elseif extension == "jsx" then
			unit_test_file = dirname .. "/" .. basename .. ".test.jsx"
		elseif extension == "ts" then
			unit_test_file = dirname .. "/" .. basename .. ".test.ts"
		elseif extension == "tsx" then
			unit_test_file = dirname .. "/" .. basename .. ".test.tsx"
		end

		if fs.is_file(unit_test_file) then
			c:service("ide").edit(unit_test_file)
		else
			vim.print("Failed to find unit test at: " .. unit_test_file)
		end
	end
end

return M
