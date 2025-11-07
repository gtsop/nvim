local assert = require("luassert")

local Controller = require("components.seeker.controller")

describe("Seeker Controller", function()
	it("instanciates", function()
		local c = Controller.new({})

		assert.is_table(c)
	end)
end)
