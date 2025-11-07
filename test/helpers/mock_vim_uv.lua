-- tests/helpers/mock_fs.lua
local uv = vim.uv
local stub = require("luassert.stub")

---@class MockFsOpts
---@field tree  table<string, {any,any}[]>?   -- dirPath -> queue of {name,kind}
---@field files table<string, string>?        -- filePath -> full file contents

local function clone_tbl(t)
	if type(t) ~= "table" then
		return t
	end
	local out = {}
	for k, v in pairs(t) do
		out[k] = clone_tbl(v)
	end
	return out
end

--- Install per-test stubs for vim.uv only: fs_scandir, fs_scandir_next,
--- fs_open, fs_read, fs_close, fs_stat.
--- Call inside a describe.
---@param opts MockFsOpts
---@param before_each fun(fn: fun())
---@param after_each  fun(fn: fun())
local function with_mock_fs(opts, before_each, after_each)
	local scandir_stub, next_stub
	local open_stub, read_stub, close_stub, stat_stub

	-- runtime state
	local tree, files
	local handles, handle_id

	before_each(function()
		tree = clone_tbl(opts.tree or {})
		files = clone_tbl(opts.files or {})
		handles = {}
		handle_id = 0

		-- Directory iteration
		scandir_stub = stub(uv, "fs_scandir", function(path)
			-- act like libuv: return a "handle" if path is a dir we know
			if tree[path] ~= nil then
				return path
			end
			return nil, "ENOTDIR"
		end)

		next_stub = stub(uv, "fs_scandir_next", function(handle)
			local q = tree[handle]
			if not q or #q == 0 then
				return nil, nil
			end
			local item = table.remove(q, 1)
			return item[1], item[2]
		end)

		-- File IO
		open_stub = stub(uv, "fs_open", function(path, _, _)
			if files[path] == nil then
				return nil, "ENOENT"
			end
			handle_id = handle_id + 1
			local key = ("H%d:%s"):format(handle_id, path)
			handles[key] = { path = path, pos = 1, closed = false }
			return key
		end)

		-- We model the sync shape for tests: fs_read(handle, n) -> chunk
		read_stub = stub(uv, "fs_read", function(handle, n)
			local h = handles[handle]
			if not h or h.closed then
				return nil, "EBADF"
			end
			local src = files[h.path] or ""
			local start = h.pos
			local stop = math.min(#src, start + (n or #src) - 1)
			if start > #src then
				return ""
			end
			local chunk = src:sub(start, stop)
			h.pos = stop + 1
			return chunk
		end)

		close_stub = stub(uv, "fs_close", function(handle)
			local h = handles[handle]
			if not h then
				return nil, "EBADF"
			end
			h.closed = true
			return true
		end)

		stat_stub = stub(uv, "fs_stat", function(path)
			if files[path] ~= nil then
				return { type = "file", size = #files[path] }
			end
			if tree[path] ~= nil then
				return { type = "directory", size = 0 }
			end
			return nil, "ENOENT"
		end)
	end)

	after_each(function()
		if scandir_stub then
			scandir_stub:revert()
		end
		if next_stub then
			next_stub:revert()
		end
		if open_stub then
			open_stub:revert()
		end
		if read_stub then
			read_stub:revert()
		end
		if close_stub then
			close_stub:revert()
		end
		if stat_stub then
			stat_stub:revert()
		end
	end)
end

return with_mock_fs
