local M = {}

function M.create(m, _, c)
	return function()
		c.using_hovered_node(function(node)
			m.expand_node(node.parent)
			c.render()
		end)
	end
end

return M
