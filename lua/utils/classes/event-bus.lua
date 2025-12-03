local EventBus = { event_table = {} }

function EventBus:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function EventBus:on(event_name, callback)
  if not self.event_table[event_name] then
    self.event_table[event_name] = {}
  end

  table.insert(self.event_table[event_name], callback)
end

function EventBus:off(event_name, callback)
  if not self.event_table[event_name] then
    self.event_table[event_name] = {}
  end

  local callbackIndex = table.index_of(self.event_table[event_name], callback)

  if callbackIndex then
    table.remove(self.event_table[event_name], callbackIndex)
  end
end

function EventBus:trigger(event_name, event_data)
  if not self.event_table[event_name] then
    self.event_table[event_name] = {}
  end

  for _, callback in ipairs(self.event_table[event_name]) do
    callback(event_data)
  end
end

return EventBus
