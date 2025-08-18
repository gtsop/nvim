local M = {}
M.__index = M

function M.new()
	local self = setmetatable({}, M)

	self.buffer = nil
	self.file = nil
	self.lines = nil

	function self.refresh()
		self.buffer = vim.api.nvim_get_current_buf()
		self.file = vim.api.nvim_buf_get_name(self.buffer)

		local lines = vim.api.nvim_buf_get_lines(self.buffer, 0, -1, false)

		self.lines = table.concat(lines, "\n")
	end

	return self
end

return M
