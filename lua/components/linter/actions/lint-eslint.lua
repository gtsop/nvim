local M = {}

function M.create(m, v, c)
  return function()
    local path = m.get_file_path()
    if path == "" then
      return
    end

    local lines = m.get_lines()
    -- --stdin-filename is required so path-aware rules (e.g. no-relative-import-paths)
    -- can autofix relative imports to absolute ones.
    -- max_exit_code=1: eslint still prints fixed code when unfixed issues remain.
    c.run_cmd(
      { "eslint_d", "--stdin", "--stdin-filename", path, "--fix-to-stdout" },
      lines,
      function(out)
        if out[#out] == "" then
          table.remove(out, #out)
        end
        v.replace_lines(out)
      end,
      { max_exit_code = 1 }
    )
  end
end

return M
