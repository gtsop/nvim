local M = {}

function M.create(m, v, c)
	return function()
		m.refresh()

		c.run_cmd({ "prettier", "--stdin-filepath", m.file }, m.lines, function(out)
			if out[#out] == "" and m.lines[#m.lines] ~= "" then
				table.remove(out, #out)
			end
			v.replace_lines(out)
		end)
	end
end

return M
