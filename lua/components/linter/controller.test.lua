local assert = require("luassert")

local LinterController = require("components.linter.controller")

describe("Linter Controller", function()
  it("instanciates", function()
    local controller = LinterController.new()

    assert.is_table(controller)
  end)
end)
