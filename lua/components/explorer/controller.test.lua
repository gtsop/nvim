local assert = require("luassert")

local Controller = require("components.explorer.controller")

local Panel = require("utils.ui.panel_v2")
local panel = Panel:new()

describe("Explorer Controller", function()
  it("instatiates", function()
    local c = Controller.new({ base_path = "/", panel = panel })

    assert.is_table(c)
  end)
end)
