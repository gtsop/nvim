-- @param path string
-- @returns string
local function extension(path)
  local base = path:match('[^/\\]+$') or path

  local first, last = base:find('%.')
  if not last or last == #base then
    return ''
  end

  return base:match('%.([^.]+)$') or ''
end

return extension
