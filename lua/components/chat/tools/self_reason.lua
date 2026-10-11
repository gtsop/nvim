local Ollama = require("utils.classes.ollama")

local ollama = Ollama:new()
ollama:select_model("qwen3.5:9b")

local function name()
  return "self.reason"
end

local function desc()
  return [[
Tool: "self.reason"
Spawns a fresh LLM context to reason about a query. Ensure you pass any context required within the query itself.
@param {string} query - The prompt sent to the LLM for reasoning
@param {string} as - Name of the variable to store the response of the LLM
@example
{ "name": "self.reason", "args": { "query": "Count the words in the following text: $some_text", "as": "response" } }
]]
end

local function exec(args, vars, engine, callback)
  ollama:prompt({
    messages = {
      {
        role = "system",
        content = "You are an IDE integrated coding assistant. When asked questions use very sort and to-the-point answers, assume the user very technivally knowledgable and only expand your answers when explicitly asked to. Even when expading, to be overly verbose",
      },
      {
        role = "user",
        content = engine.replace_variables(args.query, vars),
      },
    },
    on_stream = function(response)
      engine.print_text(response)
    end,
    on_end = function(response)
      vars[args.as] = response
      callback()
    end,
  })
end

return {
  desc = desc,
  exec = exec,
  name = name,
  on = true,
}
