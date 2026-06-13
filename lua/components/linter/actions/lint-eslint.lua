local M = {}

function M.create(m, v, c)
  return function()
    local lines = m.get_lines()
    c.run_cmd({ "eslint_d", "--stdin", "--fix-to-stdout" }, lines, function(out)
      --if out[#out] == "" and m.lines[#m.lines] ~= "" then
      -- table.remove(out, #out)
      --end
      v.replace_lines(out)
    end)
  end
end

return M
