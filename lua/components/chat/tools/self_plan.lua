local Ollama = require("utils.classes.ollama")

local ollama = Ollama:new()
ollama:select_model("qwen3.5:9b")

local function name()
  return "self.plan"
end

local function desc()
  return [[
Tool: "self.plan"
Uses an LLM engine to constructs a follow up plan to carry through
@param {string} [prompt] - Extra instructions sent to the planing engine
@example
{ "name": "self.plan", "args": { "prompt": "Some extra context needed" } }
]]
end

local function exec(args, vars, engine, callback)
  engine.plan(engine.replace_variables(args.prompt, vars))
  callback()
end

return {
  desc = desc,
  exec = exec,
  name = name,
  on = true,
}
