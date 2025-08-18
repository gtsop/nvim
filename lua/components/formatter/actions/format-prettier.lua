local M = {}

function M.create(m, v, c)
	return function()
		m.refresh()

		c.run_cmd({ "prettier", "--stdin-filepath", m.file }, m.lines, function(out)
			v.replace_lines(out)
		end)
	end
end

return M
