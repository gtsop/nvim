-- @param path string
-- @return string
local function dirname(path)
	path = path:gsub("[\\/]+$", "")

	local idx = path:find("[\\/][^\\/]*$")
	if not idx then
		return "."
	end

	local dir = path:sub(1, idx - 1)

	return dir == "" and path:sub(1, 1) or dir
end

return dirname
