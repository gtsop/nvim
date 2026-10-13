local Ollama = {}
Ollama.__index = Ollama

local last_curl_request = {}
local last_curl_response = {}

function Ollama:new(args)
  args = args or {}

  return setmetatable({
    model = nil,
    tools = args.tools,
    on_end = nil,
    on_stream = nil,
    prompt_job_id = nil,
    response = "",
  }, Ollama)
end

function Ollama:select_model(model)
  self.model = model
  self:get_model_capabilities()
end

function Ollama:get_model(model)
  return self.model
end

function Ollama:prompt(args)
  if not self.model then
    vim.print('Ollama: please select a model (ollama:select_model("model_name")')
    return
  end

  self.on_end = args.on_end
  self.on_stream = args.on_stream
  self.response = ""
  self.tool_calls = {}

  self.prompt_job_id = curl("/api/chat", {
    format = args.format,
    messages = args.messages,
    model = self.model,
    options = { temperature = 0.2, num_ctx = 32768 },
    stream = true,
    -- think = true,
    tools = self.tools,
  }, function(_, data)
    for _, line in ipairs(data) do
      if line and line ~= "" then
        local ok, decoded = pcall(vim.fn.json_decode, line)
        if ok and type(decoded) == "table" then
          -- Message response parsing
          local message = decoded.message or {}
          if message.content and message.content ~= "" then
            local token = decoded.message.content
            self.response = self.response .. token
            if args.on_stream then
              args.on_stream(self.response, token)
            end
          end

          -- Tool call response parsing
          if message.tool_calls then
            for _, call in ipairs(message.tool_calls) do
              table.insert(self.tool_calls, call)
            end
          end

          if decoded.done then
            self.prompt_eval_count = decoded.prompt_eval_count
            self.prompt_job_id = nil

            if #self.tool_calls > 0 then
              table.insert(args.messages, {
                role = "assistant",
                content = self.response,
                tool_calls = self.tool_calls,
              })

              for _, call in ipairs(self.tool_calls) do
                local name = call["function"].name
                local tool_args = call["function"].arguments or {}

                local result = args.on_call_tool(name, tool_args)

                table.insert(args.messages, {
                  role = "tool",
                  tool_name = name,
                  content = tostring(result),
                })
              end

              self:prompt(args)
            else
              table.insert(args.messages, {
                role = "assistant",
                content = self.response,
              })
              if args.on_end then
                args.on_end(self.response)
              end
            end
          end
        end
      end
    end
  end, false)
end

function Ollama:cancel()
  if self.prompt_job_id then
    vim.fn.jobstop(self.prompt_job_id)
    self.on_end(self.response)
  end
end

function Ollama:get_model_capabilities()
  curl("/api/show", { model = self.model }, function(_, data)
    local json_string = data[1]
    local ok, decoded = pcall(vim.fn.json_decode, json_string)
    if ok and decoded.model_info then
      self.model_info = decoded.model_info
    end
  end)
end

function Ollama:get_context_usage()
  local context_length = get_context_length(self.model_info)
  local latest_tokens = self.prompt_eval_count
  if not context_length or not latest_tokens then
    return 0
  end
  return latest_tokens / context_length * 100
end

function get_context_length(model_info)
  if type(model_info) ~= "table" then
    return nil
  end

  for key, value in pairs(model_info) do
    if type(key) == "string" and key:match("%.context_length$") and type(value) == "number" then
      return value
    end
  end

  return nil
end

function curl(endpoint, data, on_stdout, stdout_buffered)
  local args = {
    "curl",
    "-sN",
    "http://localhost:11434" .. endpoint,
    "-H",
    "Content-Type: application/json",
  }

  if data ~= nil then
    vim.list_extend(args, {
      "--data-binary",
      "@-",
    })
  end

  last_curl_request = { args = args, data = data }

  local job_id = vim.fn.jobstart(args, {
    stdout_buffered = stdout_buffered,
    on_stdout = function(code, data)
      last_curl_response = data
      on_stdout(code, data)
    end,
    on_stderr = function(_, data)
      last_curl_response = data
    end,
  })

  if data ~= nil then
    vim.fn.chansend(job_id, vim.fn.json_encode(data))
  end

  vim.fn.chanclose(job_id, "stdin")

  return job_id
end

function Ollama:fetch_models(callback)
  curl("/api/tags", nil, function(_, data)
    local models = {}

    local response = table.concat(data, "")
    local decoded = vim.json.decode(response)

    for _, model in ipairs(decoded.models or {}) do
      models[#models + 1] = model.name
    end

    callback(models)
  end, true)
end

vim.api.nvim_create_user_command("ChatDebugLastCurlRequest", function()
  vim.print(last_curl_request)
end, { nargs = 0 })
vim.api.nvim_create_user_command("ChatDebugLastCurlResponse", function()
  vim.print(last_curl_response)
end, { nargs = 0 })

vim.api.nvim_create_user_command("ChatDebugLastCurl", function()
  if not last_curl_request then
    vim.notify("No previous curl request", vim.log.levels.WARN)
    return
  end

  local args = vim.deepcopy(last_curl_request.args)
  local json = vim.fn.json_encode(last_curl_request.data)

  -- Replace stdin body (@-) with the actual JSON payload.
  for i, arg in ipairs(args) do
    if arg == "@-" then
      args[i] = json
      args[i - 1] = "--data-binary"
      break
    end
  end

  -- Shell-escape every argument.
  local escaped = {}
  for _, arg in ipairs(args) do
    table.insert(escaped, vim.fn.shellescape(arg))
  end

  local cmd = table.concat(escaped, " ")
  vim.fn.setreg("+", cmd)
  print(cmd)
  vim.notify("Curl command copied to clipboard")
end, {})

return Ollama
