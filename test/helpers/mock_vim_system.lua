-- tests/helpers/mock_system.lua
local stub = require("luassert.stub")

--- Mock vim.system using a tuple interface.
---
--- scenarios = {
---   { {"grep", "-R"}, { stdout="x", stderr="", code=0 } },
---   { {"echo", "hi"}, { stdout="hi\n", stderr="", code=0 } },
--- }
---
---@param scenarios { [1]:string[], [2]:{stdout:string,stderr:string,code:integer} }[]
---@param before_each fun(fn:function)
---@param after_each  fun(fn:function)
local function with_mock_system(scenarios, before_each, after_each)
	local sys_stub

	before_each(function()
		sys_stub = stub(vim, "system", function(cmd, opts)
			opts = opts or {}

			for _, tuple in ipairs(scenarios) do
				local expected_cmd = tuple[1]
				local result = tuple[2]

				-- exact list match
				if #cmd == #expected_cmd then
					local ok = true
					for i = 1, #cmd do
						if cmd[i] ~= expected_cmd[i] then
							ok = false
							break
						end
					end

					if ok then
						return {
							wait = function()
								return {
									stdout = result.stdout or "",
									stderr = result.stderr or "",
									code = result.code or 0,
								}
							end,
						}
					end
				end
			end
		end)
	end)

	after_each(function()
		if sys_stub then
			sys_stub:revert()
		end
	end)
end

return with_mock_system
