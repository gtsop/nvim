local ChatController = {}
ChatController.__index = ChatController

local Panel = require("utils.ui.panel")

local chat_history = {
  {
    role = "system",
    content = "You are an IDE integrated coding assistant. When asked questions use very sort and to-the-point answers, assume the user very technivally knowledgable and only expand your answers when explicitly asked to. Even when expading, to be overly verbose",
  },
}

function ChatController.new(opts)
  local self = setmetatable({ ide = opts.ide }, ChatController)

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buffer, "filetype", "chat")
  vim.api.nvim_buf_set_option(buffer, "modifiable", true)

  local panel = Panel:new({
    name = "chat",
    on_enter = function() end,
    on_leave = function() end,
    on_close = function() end,
    position = "bottom",
  })

  function self.show()
    panel:open({ buffer = buffer })
  end

  vim.api.nvim_create_user_command("ChatShow", self.show, { nargs = 0 })

  vim.keymap.set("n", "<CR>", function()
    vim.print("Sending prompt to ollama")
    local prompt = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    table.insert(chat_history, {
      role = "user",
      content = prompt,
    })

    local acc = ""
    ask_llm(function(token)
      acc = acc .. token
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(acc, "\n"))
    end, function()
      table.insert(chat_history, {
        role = "assistant",
        content = acc,
      })
    end)
  end, {
    buffer = buffer,
  })

  function self.print_history()
    vim.print(chat_history)
  end

  vim.api.nvim_create_user_command("ChatDebugHistory", self.print_history, { nargs = 0 })
end

function ask_llm(stream_callback, end_callback)
  vim.fn.jobstart({
    "curl",
    "-N",
    "http://localhost:11434/api/chat",
    "-H",
    "Content-Type: application/json",
    "-d",
    vim.fn.json_encode({
      model = "gemma3:4b",
      stream = true,
      messages = chat_history,
    }),
  }, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line and line ~= "" then
          local ok, decoded = pcall(vim.fn.json_decode, line)
          if ok and decoded.message and decoded.message.content then
            stream_callback(decoded.message.content)
          end
          if decoded.done then
            end_callback()
          end
        end
      end
    end,
  })
end

return ChatController
