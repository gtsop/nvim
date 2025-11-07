local list_ignore = { ".git", "node_modules", "build" }
local function list_dir_contents(path, opts)
	-- Remove trailing slash
	if path:sub(-1) == "/" then
		path = path.sub(1, -2)
	end

	opts = opts or { recurse = false, rootDir = nil }

	if opts.recurse and not opts.rootDir then
		opts.rootDir = path
	end

	local contents = {}

	local handle = vim.uv.fs_scandir(path)
	if not handle then
		return contents
	end

	while true do
		local name, typ = vim.uv.fs_scandir_next(handle)
		if not name then
			break
		end

		table.insert(contents, { name, typ })
		if typ == "directory" and opts.recurse and not table.contains(list_ignore, name) then
			local inner_contents = list_dir_contents(path .. "/" .. name, opts)
			for _, item in ipairs(inner_contents) do
				local prefix = ""
				if path == opts.rootDir then
					prefix = name .. "/"
				else
					prefix = path .. "/" .. name .. "/"
				end
				table.insert(contents, { prefix .. item[1], item[2] })
			end
		end
	end

	return contents
end

return list_dir_contents
