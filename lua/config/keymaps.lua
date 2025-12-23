-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

vim.keymap.set("n", "<leader>hk", function()
  require("luasnip.loaders").edit_snippet_files()
end, { desc = "Edit Snippets" })

vim.keymap.set("n", "<C-b>", function()
  Snacks.terminal()
end, {})
vim.keymap.set("t", "<c-b>", "<cmd>close<cr>", {})

vim.keymap.del("n", "<leader>e")

vim.keymap.set("n", "<leader>e", "<leader>E", { desc = "tree view (cwd)", remap = true })

vim.keymap.set("n", "<leader>o", "O<C-C>O<C-C>o<C-C>i", { remap = true, silent = true })

vim.keymap.set("n", "<leader>hj", "p", { desc = "paste" })
vim.keymap.set("i", "<C-b>", function()
  vim.api.nvim_paste(vim.fn.getreg("+"), false, -1)
end, { desc = "paste" })

vim.keymap.set("i", "<C-e>a", "_")
vim.keymap.set("i", "<C-e>d", "<><left>")
vim.keymap.set("i", "<C-e>l", "=")
vim.keymap.set("i", "<C-e>j", "!=")
vim.keymap.set("i", "<C-e>h", "==")
vim.keymap.set("i", "<C-e>n", "{}<left>")
vim.keymap.set("i", "<C-e>b", "{{}}<left><left>")
vim.keymap.set("i", "<C-e>m", "[]<left>")

vim.api.nvim_set_keymap("n", "<C-m>", ":delm!<CR>", {})
vim.api.nvim_set_keymap("n", "<C-e>e", "/", {})
vim.api.nvim_set_keymap("n", "<leader>m", ":MarkdownPreview<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>tg", ":!templ generate<CR>", { desc = "templ generate" })
vim.api.nvim_set_keymap("i", "<C-o>", "<CR>", {})
vim.keymap.set("n", "<leader>cli", ":LspInfo<CR>", { desc = "Lsp Info" })
vim.keymap.set("n", "<leader>clr", function()
  vim.api.nvim_command(":LspRestart")
end, { desc = "Restart buffer Lsp" })

vim.keymap.set("i", "<C-k>", require("blink.cmp").select_prev, { desc = "blink.cmp: Select previous item" })
vim.keymap.set({ "n" }, "<leader>S", ":SqlsExecuteQuery<CR>", { silent = false, desc = "Execute Query" })

-- DAP (Debug Adapter Protocol) keybindings
vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dc", "<cmd>DapContinue<CR>", { desc = "Continue" })
vim.keymap.set("n", "<leader>di", "<cmd>DapStepInto<CR>", { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", "<cmd>DapStepOver<CR>", { desc = "Step Over" })
vim.keymap.set("n", "<leader>dO", "<cmd>DapStepOut<CR>", { desc = "Step Out" })
vim.keymap.set("n", "<leader>dt", "<cmd>DapTerminate<CR>", { desc = "Terminate" })
vim.keymap.set("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>dw", function()
  require("dapui").elements.watches.add(vim.fn.input("Watch expression: "))
end, { desc = "Add Watch" })
vim.keymap.set("n", "<leader>dW", function()
  require("dapui").elements.watches.remove()
end, { desc = "Remove Watch" })

vim.keymap.set("n", "<leader>cp", ":let @+ = expand('%:p')<CR>")
