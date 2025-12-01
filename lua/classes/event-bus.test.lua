local assert = require("luassert")

local EventBus = require("classes.event-bus")

describe("EventBus", function()
  it("instanciates", function()
    local event_bus = EventBus.new()

    assert.is_table(event_bus)
  end)

  it("works", function()
    local event_bus = EventBus.new()

    local value = 0

    local callback = function(data)
      value = data
    end

    event_bus.on("foo", callback)
    event_bus.trigger("foo", 1)

    assert.equal(1, value)

    event_bus.off("foo", callback)
    event_bus.trigger("foo", 2)

    assert.equal(1, value)
  end)
end)
