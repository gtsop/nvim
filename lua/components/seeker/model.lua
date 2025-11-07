local M = {}
M.__index = M

function M.new(args)
  local self = setmetatable({}, M)

  local root_dir = args.root_dir

  function self.grep_async(pattern, callback)
    vim.system({ "grep", "-R", "-n", "-H", "--color=never", "-e", pattern, root_dir }, { text = true }, function(res)
      vim.schedule(function()
        if res.code == 0 or res.code == 1 then
          callback(res.stdout)
        else
          callback("")
        end
      end)
    end)
  end

  function self.search(needle, callback)
    self.grep_async(needle, function(lines)
      local results = {}

      for line in lines:gmatch("[^\n]+") do
        local filename, lineNo, text = line:match("^([^:\n]+):(%d+):(.*)$")

        if filename and line and text then
          table.insert(results, {
            file = filename,
            line = tonumber(lineNo),
            text = text,
          })
        end
      end

      callback(results)
    end)
  end

  return self
end

return M
