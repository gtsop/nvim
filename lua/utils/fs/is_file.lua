-- @param path string
-- @return boolean
local function is_file(path)
	local stat = vim.uv.fs_stat(vim.fs.normalize(path))
	return stat and stat.type == "file"
end

return is_file
