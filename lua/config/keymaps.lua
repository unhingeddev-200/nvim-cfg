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
  --vim.api.nvim_command(":LspRestart")
  local clients = vim.lsp.get_clients()
  for _, v in pairs(clients) do
    vim.lsp.enable(v.name, false)
    vim.lsp.enable(v.name, true)
  end
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

-- Copy Go package path to clipboard
local function copy_go_package_path()
  local filepath = vim.fn.expand("%:p")
  local filedir = vim.fn.expand("%:p:h")

  -- Find go.mod file
  local function find_go_mod(dir)
    local go_mod = dir .. "/go.mod"
    if vim.fn.filereadable(go_mod) == 1 then
      return go_mod
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      return nil
    end
    return find_go_mod(parent)
  end

  local go_mod_path = find_go_mod(filedir)
  if not go_mod_path then
    vim.notify("go.mod not found in parent directories", vim.log.levels.ERROR)
    return
  end

  -- Read module name from go.mod
  local go_mod_dir = vim.fn.fnamemodify(go_mod_path, ":h")
  local go_mod_content = vim.fn.readfile(go_mod_path)
  local module_name = nil
  for _, line in ipairs(go_mod_content) do
    local match = line:match("^module%s+(.+)$")
    if match then
      module_name = match:gsub("%s+", "")
      break
    end
  end

  if not module_name then
    vim.notify("Could not parse module name from go.mod", vim.log.levels.ERROR)
    return
  end

  -- Get relative path from go.mod directory
  local rel_path = filedir:sub(#go_mod_dir + 2) -- +2 to skip the trailing /

  -- Build the full import path
  local import_path
  if rel_path == "" or rel_path == filedir then
    -- We're in the root directory
    import_path = module_name
  else
    import_path = module_name .. "/" .. rel_path
  end

  -- Copy to system clipboard
  vim.fn.setreg("+", import_path)
  vim.notify('Copied: "' .. import_path .. '"', vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>cg", copy_go_package_path, { desc = "Copy Go package path" })
