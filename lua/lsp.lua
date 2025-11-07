vim.lsp.enable("lua_ls")
vim.lsp.enable("typescript")
vim.lsp.enable("html")
vim.lsp.enable("css")

vim.diagnostic.config({
    virtual_lines = {
        current_line = true,
    },
})

vim.keymap.set("n", "<S-M-o>", function()
    vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "source.addMissingImports.ts" } },
    })
    vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "source.organizeImports" } },
    })
end, { desc = "LSP: fix imports" })

vim.api.nvim_create_autocmd("CompleteDone", {
    callback = function(args)
        local client = vim.lsp.get_active_clients({ bufnr = 0 })[1]
        if not client then
            return
        end

        local selected_item = vim.v.completed_item

        if not selected_item then
            return
        end

        local user_data = selected_item.user_data
        if not user_data then
            return
        end

        local ok, completion_item = pcall(function()
            return user_data.nvim.lsp.completion_item
        end)

        if not ok then
            return
        end

        if
            client.server_capabilities.completionProvider
            and client.server_capabilities.completionProvider.resolveProvider
        then
            client.request("completion/resolve", completion_item, function(a, resolved)
                -- print(vim.inspect(a))
                -- print(vim.inspect(resolved))
            end)
        end
    end,
})

vim.api.nvim_create_user_command("LSPDiagnose", function()
    local client = vim.lsp.get_clients({ bufnr = 0 })

    vim.print("Has client: " .. (#client > 0 and "true" or "false"))
end, { nargs = 0 })
