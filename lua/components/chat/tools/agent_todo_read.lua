local state = require("components.chat.tools.agent_todo_state")

local function exec(args, ide)
  return state.read()
end

local name = "agent.todo_read"

local schema = {
  type = "function",
  ["function"] = {
    name = "agent.todo_read",
    description = "Read the current in-session task checklist.",
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
