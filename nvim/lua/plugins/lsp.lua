-- mason
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- mason lsp-config
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "clangd", "nil_ls", "cssls", "jsonls" },
})

-- lsp servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")
vim.lsp.enable("nixd")

-- Dynamically collect QML module directories for both Quickshell AND Qt 6 standard modules (QtQuick)
local quickshell_path = vim.fn.glob("/nix/store/*-quickshell-*/lib/qt-6/qml")
local qtdeclarative_path = vim.fn.glob("/nix/store/*-qtdeclarative-*/lib/qt-6/qml")

-- Fall back to standard NixOS system paths if globs return empty
local import_paths = table.concat({
  quickshell_path,
  qtdeclarative_path,
  "/run/current-system/sw/lib/qt-6/qml",
  vim.fn.expand("~/.nix-profile/lib/qt-6/qml"),
}, ":")

vim.lsp.config('qmlls', {
  cmd = { 
    'qmlls', 
    '-I', quickshell_path,
    '-I', qtdeclarative_path,
  },
  cmd_env = {
    QML2_IMPORT_PATH = import_paths,
  },
  on_init = function(client)
    -- Keeps semantic token crashes disabled
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

vim.lsp.enable('qmlls')
vim.lsp.enable("cssls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("jsonls")
