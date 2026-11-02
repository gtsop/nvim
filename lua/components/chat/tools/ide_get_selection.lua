local shared = require("components.chat.tools._shared")

local function exec(args, ide)
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_buf, start_line, start_col = start_pos[1], start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  if start_line == 0 or end_line == 0 then
    return "Error: no visual selection marks available"
  end

  local bufnr = start_buf
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return "Error: selection buffer is invalid"
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  local resolved, err = shared.resolve_project_path(path, { must_exist = true })
  if err then
    return err
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  if #lines == 0 then
    return "Error: empty selection"
  end

  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  local header = string.format(
    "file: %s\nselection: %d:%d-%d:%d\n",
    shared.relativize(resolved),
    start_line,
    start_col,
    end_line,
    end_col
  )
  return shared.truncate_text(header .. table.concat(lines, "\n"), args and args.max_bytes)
end

local name = "ide.get_selection"

local schema = {
  type = "function",
  ["function"] = {
    name = "ide.get_selection",
    description = "Return the last visual selection text from a project file ('<,'>).",
    parameters = {
      type = "object",
      properties = {
        max_bytes = {
          type = "number",
          description = "Hard cap on returned bytes.",
        },
      },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
