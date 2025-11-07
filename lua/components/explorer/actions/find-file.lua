local M = {}

function M.create(m, v, c)
	return function()
		local file = vim.api.nvim_buf_get_name(0)
		c.show()
		local node = m.expand_until_path(file)
		c.render()
		v.hover_node(node)
		vim.cmd("normal! zz")
	end
end

return M
