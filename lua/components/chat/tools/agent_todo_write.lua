local state = require("components.chat.tools.agent_todo_state")

local function exec(args, ide)
  args = args or {}
  local todos = args.todos
  -- Ollama may pass JSON as a string
  if type(todos) == "string" then
    local ok, decoded = pcall(vim.fn.json_decode, todos)
    if ok then
      todos = decoded
    end
  end
  local ok, err = state.write(todos)
  if not ok then
    return err
  end
  return "Updated todos (" .. #state.items .. "):\n" .. state.read()
end

local name = "agent.todo_write"

local schema = {
  type = "function",
  ["function"] = {
    name = "agent.todo_write",
    description = "Replace the in-session task checklist. Keep plans here instead of long chat messages. Each item: {id, content, status}.",
    parameters = {
      type = "object",
      properties = {
        todos = {
          type = "array",
          description = "Full todo list to store.",
          items = {
            type = "object",
            properties = {
              id = { type = "string" },
              content = { type = "string" },
              status = {
                type = "string",
                description = "pending | in_progress | completed | cancelled",
              },
            },
          },
        },
      },
      required = { "todos" },
    },
  },
}

return {
  _enabled = true,
  exec = exec,
  name = name,
  schema = schema,
}
