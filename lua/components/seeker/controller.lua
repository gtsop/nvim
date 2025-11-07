local M = {}
M.__index = M

local Model = require("components.seeker.model")

function M.new(opts)
	local self = setmetatable({ di = { providers = {}, instances = {} } }, M)

	local model = Model.new({ root_dir = opts.base_path })

	function self.seek(opts)
		vim.print("grepping for " .. opts.args)
		model.search(opts.args, function(results)
			vim.print(results)
		end)
	end

	vim.api.nvim_create_user_command("SeekerFind", self.seek, { nargs = 1 })

	return self
end

return M
