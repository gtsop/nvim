local function exec(args, ide)
  return "disabled pending formatter path API: format a path and return result/diff (see REVIEW on formatter controller)"
end

local name = "project.format_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.format_file",
    description = "DISABLED. Will format a project file once a path-based formatter API exists.",
    parameters = {
      type = "object",
      properties = {
        path = { type = "string", description = "Project file path." },
      },
      required = { "path" },
    },
  },
}

return {
  _enabled = false,
  exec = exec,
  name = name,
  schema = schema,
}
