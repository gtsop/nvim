local M = {}
M.__index = M

local Model = require("components.seeker.model")
local View = require("components.seeker.view")

function M.new(opts)
  local self = setmetatable({ di = { providers = {}, instances = {} } }, M)

  local model = Model.new({ root_dir = opts.base_path })
  local view = View.new()

  function self.seek(cargs)
    model.search(cargs.args, function(results)
      view.render(results)
      view.show()
    end)
  end

  function self.show()
    view.show()
  end

  vim.api.nvim_create_user_command("SeekerFind", self.seek, { nargs = 1 })

  return self
end

return M
