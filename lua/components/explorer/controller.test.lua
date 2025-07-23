local assert = require("luassert")

local Controller = require("components.explorer.controller")

describe("Explorer Controller", function()

  it("instatiates", function()
    local c = Controller.new()

    assert.is_table(c)
  end)

  it("has an 'open' method", function()
    local c = Controller.new()

    assert.is_function(c.open)
  end)
end)
