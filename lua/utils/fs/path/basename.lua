-- @param path       string
-- @param strip_ext? boolean
-- @return string
local function basename(path, strip_ext)
	local name = path:match("[^/\\]+$") or path

	if strip_ext then
		if name:sub(1, 1) ~= "." then
			local base = name:match("^(.*)%.[^.]+$")
			if base and base ~= "" then
				name = base
			end
		end
	end

	return name
end

return basename
