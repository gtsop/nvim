local shared = require("components.chat.tools._shared")

local function most_recent_project_file_buf()
  local most_recent_bufnr = nil
  local most_recent_time = -1
  for _, buf in ipairs(vim.fn.getbufinfo()) do
    local bufnr = buf.bufnr
    local path = buf.name
    if
      vim.api.nvim_buf_is_valid(bufnr)
      and vim.bo[bufnr].buftype == ""
      and path ~= ""
      and vim.fn.filereadable(path) == 1
      and shared.is_under_project(path)
      and buf.lastused > most_recent_time
    then
      most_recent_bufnr = bufnr
      most_recent_time = buf.lastused
    end
  end
  return most_recent_bufnr
end

local function exec(args, ide)
  args = args or {}
  local before = shared.tonumber_arg(args.before, shared.DEFAULTS.context_before)
  local after = shared.tonumber_arg(args.after, shared.DEFAULTS.context_after)

  local bufnr = most_recent_project_file_buf()
  if not bufnr then
    return "No project file is currently being edited"
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  local resolved, err = shared.resolve_project_path(path, { must_exist = true })
  if err then
    return err
  end

  local win = nil
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(w) == bufnr then
      win = w
      break
    end
  end

  local cursor_line = 1
  local cursor_col = 0
  if win then
    local pos = vim.api.nvim_win_get_cursor(win)
    cursor_line = pos[1]
    cursor_col = pos[2]
  elseif ide and ide.get_current_line then
    cursor_line = ide.get_current_line() or 1
  end

  local total = vim.api.nvim_buf_line_count(bufnr)
  local start_line = math.max(1, cursor_line - before)
  local end_line = math.min(total, cursor_line + after)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

  local header = string.format(
    "file: %s\ncursor: %d:%d\nlines %d-%d of %d\n",
    shared.relativize(resolved),
    cursor_line,
    cursor_col + 1,
    start_line,
    end_line,
    total
  )
  return shared.truncate_text(header .. shared.format_lines(lines, start_line), args.max_bytes)
end

local name = "ide.get_context"

local schema = {
  type = "function",
  ["function"] = {
    name = "ide.get_context",
    description = "Return the active project file path, cursor position, and a small window of surrounding lines (default ±20).",
    parameters = {
      type = "object",
      properties = {
        before = {
          type = "number",
          description = "Lines before cursor (default 20).",
        },
        after = {
          type = "number",
          description = "Lines after cursor (default 20).",
        },
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
