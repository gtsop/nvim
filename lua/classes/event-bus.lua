local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
  local self = setmetatable({}, EventBus)

  local event_table = {}

  function self.on(event_name, callback)
    if not event_table[event_name] then
      event_table[event_name] = {}
    end

    table.insert(event_table[event_name], callback)
  end

  function self.off(event_name, callback)
    if not event_table[event_name] then
      event_table[event_name] = {}
    end

    local callbackIndex = table.index_of(event_table[event_name], callback)

    if callbackIndex then
      table.remove(event_table[event_name], callbackIndex)
    end
  end

  function self.trigger(event_name, event_data)
    if not event_table[event_name] then
      event_table[event_name] = {}
    end

    for _, callback in ipairs(event_table[event_name]) do
      callback(event_data)
    end
  end

  return self
end

return EventBus
