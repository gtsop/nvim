local function exec(args, ide)
  local most_recent_path = nil
  local most_recent_time = -1

  for _, buf in ipairs(vim.fn.getbufinfo()) do
    local bufnr = buf.bufnr
    local path = buf.name

    if
      vim.api.nvim_buf_is_valid(bufnr)
      and vim.bo[bufnr].buftype == ""
      and path ~= ""
      and vim.fn.filereadable(path) == 1
      and buf.lastused > most_recent_time
    then
      most_recent_path = path
      most_recent_time = buf.lastused
    end
  end

  return most_recent_path or "No file is currently being edited"
end

local name = "ide.get_current_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "ide.get_current_file",
    description = "Returns the absolute path of the most recently active regular file buffer in Neovim.",
    parameters = {
      type = "object",
      properties = vim.empty_dict(),
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
