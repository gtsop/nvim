local M = {}
M.__index = M

local Model = require("components.seeker.model")
local View = require("components.seeker.view")

function M.new(opts)
  local self = setmetatable({ di = { providers = {}, instances = {} } }, M)

  local model = Model.new({ root_dir = opts.base_path })
  local view = View.new()

  local window = nil
  local group = nil

  function self.seek(opts)
    model.search(opts.args, function(results)
      view.render(results)
      view.show()
    end)
  end

  function self.show()
    if window then
      vim.api.nvim_set_current_win(window)
      return
    end

    view.show()

    window = view.get_window()

    group = vim.api.nvim_create_augroup(("seeker_%d"):format(window), { clear = true })
  end

  vim.api.nvim_create_user_command("SeekerFind", self.seek, { nargs = 1 })

  return self
end

return M
