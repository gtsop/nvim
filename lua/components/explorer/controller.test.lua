local assert = require("luassert")

local Controller = require("components.explorer.controller")

describe("Explorer Controller", function()

  it("instatiates", function()
    local c = Controller.new({ base_path = "/" })

    assert.is_table(c)
  end)
end)
