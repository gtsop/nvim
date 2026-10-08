local Ollama = {}
Ollama.__index = Ollama

function Ollama:new(args)
  args = args or {}

  return setmetatable({
    model = nil,
    on_end = nil,
    on_stream = nil,
    promopt_job_id = nil,
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
  self.prompt_job_id = curl("/api/chat", {
    model = self.model,
    stream = true,
    messages = args.messages,
    format = args.format,
    options = {
      temperature = 0.2,
    },
  }, function(_, data)
    for _, line in ipairs(data) do
      if line and line ~= "" then
        local ok, decoded = pcall(vim.fn.json_decode, line)
        if ok and decoded.message and decoded.message.content then
          local token = decoded.message.content
          self.response = self.response .. token
          if args.on_stream then
            args.on_stream(self.response, token)
          end
        end
        if decoded.done then
          self.prompt_eval_count = decoded.prompt_eval_count
          args.on_end(self.response)
          self.prompt_job_id = nil
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
  local job_id = vim.fn.jobstart({
    "curl",
    "-N",
    "http://localhost:11434" .. endpoint,
    "-H",
    "Content-Type: application/json",
    "--data-binary",
    "@-",
  }, {
    stdout_buffered = stdout_buffered,
    on_stdout = on_stdout,
  })

  vim.fn.chansend(job_id, vim.fn.json_encode(data))
  vim.fn.chanclose(job_id, "stdin")

  return job_id
end

return Ollama
