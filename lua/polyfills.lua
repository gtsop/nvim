function table.contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

function table.clone(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[table.clone(orig_key, copies)] = table.clone(orig_value, copies)
            end
            setmetatable(copy, table.clone(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.extend(a, b)
  table.move(b, 1, #b, #a + 1, a)
end

function table.map(list, mapper)
  assert(type(list)   == 'table',   'table.map: list must be a table')
  assert(type(mapper) == 'function','table.map: mapper must be a function')

  local into = {}

  for i = 1, #list do
    into[i] = mapper(list[i], i, list)
  end
  return into
end
