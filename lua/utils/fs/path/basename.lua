-- @param path string
-- @return string
local function basename(path)
  return path:match("[^/\\]+$")
end

return basename
