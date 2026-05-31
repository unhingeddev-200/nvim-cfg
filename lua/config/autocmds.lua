---@diagnostic disable: unused-local, unused-function
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client.name == "slangd" then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end,
})

--- slangd can leave duplicate AST state after a write (Tu “stacked”; fix is didClose+didOpen).
local slangd_au = vim.api.nvim_create_augroup("config_slangd_soft_resync", { clear = true })

---@param bufnr integer
local function slangd_soft_resync(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "slangd" })
  if #clients == 0 then
    return
  end
  local ids = vim.tbl_map(function(c)
    return c.id
  end, clients)
  for _, id in ipairs(ids) do
    pcall(vim.lsp.buf_detach_client, bufnr, id)
  end
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    for _, id in ipairs(ids) do
      if vim.lsp.get_client_by_id(id) then
        pcall(vim.lsp.buf_attach_client, bufnr, id)
      end
    end
  end)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = slangd_au,
  callback = function(args)
    local bufnr = args.buf
    if #vim.lsp.get_clients({ bufnr = bufnr, name = "slangd" }) == 0 then
      return
    end
    vim.b[bufnr].config_slangd_write_seq = (vim.b[bufnr].config_slangd_write_seq or 0) + 1
    local seq = vim.b[bufnr].config_slangd_write_seq
    vim.defer_fn(function()
      if not vim.api.nvim_buf_is_valid(bufnr) or vim.b[bufnr].config_slangd_write_seq ~= seq then
        return
      end
      slangd_soft_resync(bufnr)
    end, 120)
  end,
})
-- Filetype detection for MDX files
vim.filetype.add({
  extension = {
    mdx = "mdx",
    slang = "shaderslang", -- slangd attaches as shaderslang / hlsl; matches tree-sitter in ts-manager
  },
})
---@param txt string[]
---@param buf? integer
---@return integer
local print_to_buf = function(txt, buf)
  local start = 0
  local end_ = 0

  if buf == nil then
    buf = vim.api.nvim_create_buf(false, true)
    start = 0
    end_ = -1
  else
    start = vim.api.nvim_buf_line_count(buf)
    end_ = start
  end
  vim.api.nvim_buf_set_lines(buf, start, end_, false, txt)
  -- Calculate window size
  local width = math.floor(vim.o.columns / 2)
  local height = #txt
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Window options
  local opts = {
    relative = "editor",
    width = width,
    height = (height > 0) and height or 1,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = "Info",
    title_pos = "center",
  }
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.keymap.set("n", "q", ":close<CR>", { buffer = buf })
  return buf
end

local late_binds = {
  pattern = "*",
  callback = function()
    -- vim.keymap.set({ "n", "v", "i" }, "<C-l>", "<CR>", { buffer = false, remap = true, silent = true })
    vim.keymap.set({ "n", "v", "i" }, "<C-c>", "<ESC>", { buffer = false, remap = false, silent = true })
    vim.keymap.set("i", "<C-k>", require("blink.cmp").select_prev, { desc = "blink.cmp: Select previous item" })
  end,
}

vim.api.nvim_create_autocmd("VimEnter", late_binds)
vim.api.nvim_create_autocmd("LspAttach", late_binds)

vim.api.nvim_create_autocmd("TermEnter", {
  callback = function()
    vim.keymap.set("t", "<C-j>", "<C-j>", { buffer = true, remap = true, silent = true })
    vim.keymap.set("t", "<C-h>", "<C-h>", { buffer = true, remap = true, silent = true })
    vim.keymap.set("t", "<C-l>", "<C-l>", { buffer = true, remap = false, silent = true })
    vim.keymap.set("t", "<C-k>", "<C-k>", { buffer = true, remap = false, silent = true })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.go", "*.templ", "justfile", "*.just", "Justfile" },
  callback = function()
    vim.keymap.set("i", "<C-e>k", ":=")
    pcall(function()
      vim.cmd("iunmap <C-e>hj")
    end)
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.ex", "*.exs" },
  callback = function(ev)
    vim.keymap.set("i", "<C-e>k", "->")
  end,
})

-- vim.api.nvim_create_autocmd("BufEnter", {
--   callback = function()
--     vim.keymap.set({ "n" }, "<leader>e", function()
--       require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
--     end, { desc = "Explorer NeoTree (Root Dir)" })
--   end,
--   pattern = { "*.sql" },
-- })

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.ex", "*.exs" },
  callback = function()
    vim.keymap.set("i", "<C-e>k", "->")
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.zig" },
  callback = function()
    vim.keymap.set("i", "<C-e>d", "@")
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.go", "*.templ" },
  callback = function()
    vim.keymap.set("i", "<C-e>k", ":=")
    vim.keymap.set("i", "<C-e>d", "<-")
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.fish" },
  callback = function()
    vim.keymap.set("i", "<C-e>d", "$")
  end,
})
-- Auto-save configuration: automatically save files without prompting
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modifiable and vim.bo.modified then
      vim.cmd("silent! write")
    end
  end,
})
vim.api.nvim_create_autocmd("LspAttach", {
  pattern = { "*" },
  callback = function()
    vim.keymap.set("i", "<C-k>", require("blink.cmp").select_prev, { desc = "blink.cmp: Select previous item" })
  end,
})
-- vim.api.nvim_create_autocmd({ "LspAttach" }, {
--   pattern = { "*.sql" },
--   callback = function()
--     local get_driver = function()
--       local cmd = vim.lsp.get_clients({ name = "sqls" })[1].config.cmd
--       local conf_path = cmd[3]
--       local conf = vim.fn.readfile(conf_path)
--       local buf = print_to_buf(conf)
--       for i = 1, #conf do
--         print_to_buf(conf[i], buf)
--         local matches = vim.fn.matchlist(conf[i], '.*driver: (.+)')
--         if #matches > 0 then
--           print_to_buf({ matches[2] })
--         end
--       end
--     end
--     get_driver()
--   end
-- })

-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--   pattern = { "*.sql" },
--   callback = function()
--
--     vim.system({"sql-formatter","--fix","-l",""})
--   end
-- })

-- -- LSP keybindings on attach
-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     local bufnr = args.buf
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client ~= nil then
--       -- Keybindings for LSP
--       local opts = { buffer = bufnr, silent = true }
--
--       -- Code actions
--       vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,
--         vim.tbl_extend("force", opts, { desc = "Code Action (vim.lsp)" }))
--
--       -- Rename
--       vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
--
--       -- Other useful LSP keymaps
--       vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Goto Definition" }))
--       vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Goto References" }))
--       vim.keymap.set("n", "gI", vim.lsp.buf.implementation,
--         vim.tbl_extend("force", opts, { desc = "Goto Implementation" }))
--       vim.keymap.set("n", "gy", vim.lsp.buf.type_definition,
--         vim.tbl_extend("force", opts, { desc = "Goto Type Definition" }))
--       vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Goto Declaration" }))
--       vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
--       vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature Help" }))
--       --vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature Help" }))
--     end
--   end,
-- })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "justfile", "Justfile", "*.just" },
  callback = function()
    local obj = vim.system({ "just", "-f", vim.fn.expand("%"), "--fmt" }, { text = true }):wait()
    if obj.code ~= 0 then
      vim.notify(obj.stderr, vim.log.levels.INFO)
    else
      vim.cmd.edit()
    end
  end,
})

local LUNAYA_MARKER = "Lunaya_Core_API.postman_collection.json"

---@return string?
local function lunaya_root()
  local cwd = vim.fn.getcwd()
  if vim.fn.filereadable(cwd .. "/" .. LUNAYA_MARKER) == 1 then
    return cwd
  end
  return LazyVim.root.detectors.pattern(0, LUNAYA_MARKER)[1]
end

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local root = lunaya_root()
    if not root then
      return
    end
    vim.fn.chansend(vim.v.event.buf, "export PYTHONPATH=" .. vim.fn.shellescape(root) .. "\r")
  end,
})
