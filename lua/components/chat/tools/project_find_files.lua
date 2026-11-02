local shared = require("components.chat.tools._shared")
local utils = require("utils")

local function exec(args, ide)
  args = args or {}
  local query = args.query
  if not query or query == "" then
    return "ArgError: 'query' is required"
  end

  local root = shared.project_root()
  local files = utils.list_dir_files(root, true)
  local relative = {}
  for _, f in ipairs(files) do
    table.insert(relative, shared.relativize(f))
  end

  local ranked = utils.rank_by_subsequence(relative, query)
  local limit = shared.tonumber_arg(args.limit, 20)
  local slice = utils.tbl_slice(ranked, 1, limit)

  if #slice == 0 then
    return "(no files matched query)"
  end

  local out = {}
  for _, item in ipairs(slice) do
    table.insert(out, item.value)
  end
  return table.concat(out, "\n")
end

local name = "project.find_files"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.find_files",
    description = "Fuzzy-rank project files by a subsequence query. Prefer this over listing all files when looking for a name.",
    parameters = {
      type = "object",
      properties = {
        query = {
          type = "string",
          description = "Subsequence / fuzzy query (e.g. 'chtctrl' for chat/controller).",
        },
        limit = {
          type = "number",
          description = "Max results (default 20).",
        },
      },
      required = { "query" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
