local Ollama = {}
Ollama.__index = Ollama

function Ollama:new(args)
  args = args or {}

  return setmetatable({
    model = args.model or "gemma3:4b",
    on_end = nil,
    on_stream = nil,
    promopt_job_id = nil,
    response = "",
  }, Ollama)
end

function Ollama:select_model(model)
  self.model = model
end

function Ollama:get_model(model)
  return self.model
end

function Ollama:prompt(args)
  vim.print("prompting...")
  self.on_end = args.on_end
  self.on_stream = args.on_stream
  self.response = ""
  self.prompt_job_id = vim.fn.jobstart({
    "curl",
    "-N",
    "http://localhost:11434/api/chat",
    "-H",
    "Content-Type: application/json",
    "-d",
    vim.fn.json_encode({
      model = self.model,
      stream = true,
      messages = args.messages,
    }),
  }, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line and line ~= "" then
          local ok, decoded = pcall(vim.fn.json_decode, line)
          if ok and decoded.message and decoded.message.content then
            local token = decoded.message.content
            self.response = self.response .. token
            args.on_stream(self.response, token)
          end
          if decoded.done then
            vim.print("done")
            args.on_end(self.response)
            self.prompt_job_id = nil
          end
        end
      end
    end,
  })
end

function Ollama:cancel()
  if self.prompt_job_id then
    vim.print("cancelled")
    vim.fn.jobstop(self.prompt_job_id)
    self.on_end(self.response)
  end
end

return Ollama
