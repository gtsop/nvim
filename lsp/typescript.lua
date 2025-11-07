return {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
	root_markers = { ".git", "package.json" },
	capabilities = vim.lsp.protocol.make_client_capabilities(),
	init_options = {
		preferences = {
			includeCompletionsForModuleExports = true,
			includeCompletionsWithInsertText = true,
			includeAutomaticOptionalChainCompletions = true,

			includeInlayParameterNameHints = "all",
			includeInlayParameterNameHintsWhenArgumentMatchesName = false,
			includeInlayFunctionParameterTypeHints = true,
		},
	},
}
