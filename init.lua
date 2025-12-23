-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("luasnip.loaders.from_lua").load({ paths = { "~/.config/luasnip" } })
require("comfy-line-numbers").setup({
  labels = {
    "1",
    "2",
    "3",
    "4",
    "5",
    "11",
    "12",
    "13",
    "14",
    "21",
    "22",
    "23",
    "24",
    "31",
    "32",
    "33",
    "34",
    "41",
    "42",
    "43",
    "44",
    "111",
    "112",
    "113",
    "114",
    "121",
    "122",
    "123",
    "124",
    "131",
    "132",
    "133",
    "134",
    "141",
    "142",
    "143",
    "144",
    "211",
    "212",
    "213",
    "214",
    "221",
    "222",
    "223",
    "224",
    "231",
    "232",
    "233",
    "234",
    "241",
    "242",
    "243",
    "244",
  },
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = false,
      },
    },
  },
})

vim.lsp.config("zls", {
  settings = {
    zls = {},
  },
})

-- Vim LSP configs
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      -- Analysis settings
      analyses = {
        unusedparams = true,
        shadow = false,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },

      -- Static check analyzers
      staticcheck = false,

      -- Gofumpt formatting (stricter than gofmt)
      gofumpt = true,

      -- Semantic tokens
      semanticTokens = false,

      -- Code lenses
      codelenses = {
        gc_details = true,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },

      -- Hints (inlay hints)
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },

      -- Completion settings
      usePlaceholders = false,
      completeUnimported = true,

      -- Diagnostics
      diagnosticsDelay = "100ms",

      -- Workspace settings
      directoryFilters = {
        "-node_modules",
        "-vendor",
      },

      -- Experimental features
      experimentalPostfixCompletions = true,
    },
  },

  -- on_attach = function(client, bufnr)
  --   -- Your custom on_attach logic
  -- end,

  -- Filetypes
  filetypes = { "go", "gomod", "gowork", "gotmpl" },

  -- Root directory detection
  -- root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),

  -- Command override (if needed)
  cmd = { "gopls" },

  -- Additional init_options
  init_options = {
    usePlaceholders = true,
  },
})
vim.lsp.config("elixirls", {
  cmd = { "/home/havok/bin/lsp/elixir-ls/language_server.sh" },
})
vim.lsp.config("denols", {})
vim.lsp.config("ts_ls", {})

-- Configure protols for Protocol Buffers
vim.lsp.config("protols", {
  cmd = { "protols" },
  filetypes = { "proto" },
})

-- Disable the built-in SQL completion keymaps that use <C-c>
vim.g.omni_sql_no_default_maps = 1

-- Configure sqls for SQL with database-aware completion
-- vim.lsp.config("sqls", {
--   cmd = { "sqls" },
--   filetypes = { "sql", "mysql", "plsql" },
--   settings = {
--     sqls = {
--       connections = {
--         -- Connections will be loaded from .sqls/config.yml in project root
--         -- This allows per-project database configuration
--       },
--     },
--   },
--   on_attach = function(client, bufnr)
--     -- Disable sqls formatting capability (use conform.nvim with sql-formatter instead)
--     client.server_capabilities.documentFormattingProvider = false
--     client.server_capabilities.documentRangeFormattingProvider = false
--
--     require("sqls").on_attach(client, bufnr)
--   end,
-- })

-- Vim LSP enable
vim.lsp.enable("ts_ls", false)
vim.lsp.enable("denols", true)
vim.lsp.enable("lua_ls", true)
vim.lsp.enable("gopls", true)
vim.lsp.enable("html", true)
vim.lsp.enable("cssls", true)
vim.lsp.enable("tailwindcss", true)
vim.lsp.enable("yamlls", true)
vim.lsp.enable("elixirls", true)
vim.lsp.enable("jsonls", true)
vim.lsp.enable("fish-lsp", true)
vim.lsp.enable("zls", true)
vim.lsp.enable("helm_ls", true)
vim.lsp.enable("rust_analyzer", true)
vim.lsp.enable("dockerls", true)
vim.lsp.enable("cue", true)
vim.lsp.enable("pyright", true)
vim.lsp.enable("protols", true)
vim.lsp.enable("clangd", true)
vim.lsp.enable("dartls", true)

function _G.print_to_buffer(data)
  vim.cmd("new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false

  local lines
  if type(data) == "string" then
    lines = vim.split(data, "\n")
  else
    lines = vim.split(vim.inspect(data), "\n")
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end
