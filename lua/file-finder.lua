vim.api.nvim_create_user_command("FileFinderPrompt", function()
  vim.print("ran command")
  vim.ui.input({ prompt = "File: " }, function(choice)

  end)
end, { nargs = 0 })
