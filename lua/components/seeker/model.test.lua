local assert = require("luassert")

local mock_vim_system = require("test.helpers.mock_vim_system")

local Model = require("components.seeker.model")

describe("Seeker Model", function()
	mock_vim_system({
		{
			{ "grep", "-R", "-n", "-H", "--color=never", "-e", "NONE", "/root" },
			{ stdout = "", stderr = "", code = 1 },
		},
	}, before_each, after_each)

	it("instanciates", function()
		local m = Model.new({})

		assert.is_table(m)
	end)

	--[[
  test("'search' greps the project tree but finds no results", function()
		local m = Model.new({ root_dir = "/root" })

		assert.async(function()
			m.search("NONE", function(results)
				assert.are.same(results, {})
			end)
		end)
	end)

	test("'search' greps the project tree and returns results", function(done)
		local m = Model.new({ root_dir = "/root" })

		m.search("foo", function(results)
			assert.are.same(results, {
				["/root/index.js"] = { ["line"] = 1, ["text"] = "foo bar" },
			})
			done()
		end)
	end)
  ]]
end)
