-- tests/helpers/mock_fs.lua  ----------------------------------------
local uv   = vim.uv
local stub = require('luassert.stub')

---Installs per‑test stubs for fs_scandir / fs_scandir_next.
---Call this **inside** a `describe` to scope it to that block.
---@param tree table<string, {any,any}[]>   -- path → queue of {name,kind}
local function with_mock_fs(origTree, before_each, after_each)
  local scandir_stub, next_stub
  local tree = nil

  before_each(function()
    tree = table.clone(origTree)

    scandir_stub = stub(uv, 'fs_scandir', function(path) return path end)

    next_stub = stub(uv, 'fs_scandir_next', function(handle)
      local q = tree[handle]       -- queue for this “dir”
      if not q or #q == 0 then
        return nil, nil            -- iteration finished
      end
      local item = table.remove(q, 1)
      return item[1], item[2]
    end)
  end)

  after_each(function()
    scandir_stub:revert()
    next_stub:revert()
  end)
end

return with_mock_fs

