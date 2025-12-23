---@diagnostic disable: unused-local, unused-function
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
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
    relative = 'editor',
    width = width,
    height = (height > 0) and height or 1,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = 'Info',
    title_pos = 'center'
  }
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.keymap.set("n", "q", ":close<CR>", { buffer = buf })
  return buf
end

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.keymap.set({ "n", "v", "i" }, "<C-l>", "<CR>", { buffer = false, remap = true, silent = true })
    vim.keymap.set({ "n", "v", "i" }, "<C-c>", "<ESC>", { buffer = false, remap = true, silent = true })
    vim.keymap.set("i", "<C-k>", require("blink.cmp").select_prev, { desc = "blink.cmp: Select previous item" })
  end,
})

vim.api.nvim_create_autocmd("TermEnter", {
  callback = function()
    vim.keymap.set("t", "<C-j>", "<C-j>", { buffer = true, remap = true, silent = true })
    vim.keymap.set("t", "<C-h>", "<C-h>", { buffer = true, remap = true, silent = true })
    vim.keymap.set("t", "<C-l>", "<C-l>", { buffer = true, remap = false, silent = true })
    vim.keymap.set("t", "<C-k>", "<C-k>", { buffer = true, remap = false, silent = true })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.go", "*.templ" },
  callback = function()
    vim.keymap.set("i", "<C-e>k", ":=")
    pcall(function()
      vim.cmd('iunmap <C-e>hj')
    end)
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.ex", "*.exs" },
  callback = function()
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
  pattern = { "*.go", "*.templ" },
  callback = function()
    vim.keymap.set("i", "<C-e>k", ":=")
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
-- Sqls
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.sql" },
  callback = function()
    local buffer_dir = vim.fn.expand("%:p:h")
    local matches = vim.fs.find(".sqls.yaml", { upward = true, path = buffer_dir })
    vim.lsp.config("sqls", {
      cmd = { "sqls", "-config", matches[1] },
      root_markers = { ".sqls.yaml" },
      filetypes = { "sql" }
    })
    vim.lsp.enable("sqls", true)
  end
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

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*.fish' },
  callback = function()
    vim.lsp.start({
      name = 'fish-lsp',
      cmd = { 'fish-lsp', 'start' },
    })
  end,
})
