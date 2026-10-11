local function name()
  return "user.reply"
end

local function desc()
  return [[
Tool: "user.reply"
Prints text on the screen so the user can see it
@param {string} response - The text to be printed
@example
{ "name": "user.reply", "args": { "response": "The result of your calculation is $result" } }
]]
end

local function exec(args, vars, engine, callback)
  local response = engine.replace_variables(args.response, vars)
  engine.append_chat_history({
    role = "assisntant",
    content = response,
  })
  engine.print_text(response)
  callback()
end

return {
  desc = desc,
  exec = exec,
  name = name,
  on = true,
}
