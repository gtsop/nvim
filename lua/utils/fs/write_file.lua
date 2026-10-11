local function write_file(path, content)
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

return write_file
