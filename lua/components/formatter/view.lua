local M = {}
M.__index = {}

function M.new()
	local self = setmetatable({}, M)

	function self.replace_lines(lines)
		local view = vim.fn.winsaveview()

		local buffer = vim.api.nvim_get_current_buf()

		vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

		vim.fn.winrestview(view)
	end

	return self
end

return M
