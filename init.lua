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

vim.lsp.config("nimls", {
  cmd = { "nimlsp" },
  filetypes = { "nim" },
  root_dir = function(bufnr, on_dir)
    local util = require("lspconfig.util")
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(
      util.root_pattern("*.nimble")(fname) or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
    )
  end,
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
      buildFlags = { "-tags=unittests" },
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

vim.lsp.config("denols", {})
vim.lsp.config("ts_ls", {})

-- Configure protols for Protocol Buffers
vim.lsp.config("protols", {
  cmd = { "protols" },
  filetypes = { "proto" },
})

-- Resolve directory containing typescript.js (astro-ls requires typescript.tsdk on every initialize).
local function resolve_typescript_lib(root_dir)
  local util = require("lspconfig.util")
  root_dir = (root_dir and root_dir ~= "" and root_dir) or vim.fn.getcwd()
  local tsdk = util.get_typescript_server_path(root_dir)
  if tsdk ~= "" and vim.fn.isdirectory(tsdk) == 1 then
    return tsdk
  end
  -- Project-local TS via Node (handles hoisted / nonstandard node_modules layouts)
  local node_cmd = string.format(
    'cd %s && node -e \'try{const p=require("path");const t=require.resolve("typescript/package.json");process.stdout.write(p.join(p.dirname(t),"lib"))}catch{process.exit(1)}\'',
    vim.fn.shellescape(root_dir)
  )
  local out = vim.trim(vim.fn.system({ "sh", "-c", node_cmd }))
  if vim.v.shell_error == 0 and out ~= "" and vim.fn.isdirectory(out) == 1 then
    return out
  end
  -- npm global install: $(npm root -g)/typescript/lib
  local npmg = vim.trim(vim.fn.system({ "npm", "root", "-g" }))
  if vim.v.shell_error == 0 and npmg ~= "" then
    local g = npmg .. "/typescript/lib"
    if vim.fn.isdirectory(g) == 1 then
      return g
    end
  end
  -- mise Node installs (any version)
  for _, p in
    ipairs(
      vim.fn.glob(vim.fn.expand("~/.local/share/mise/installs/node/*/lib/node_modules/typescript/lib"), false, true)
    )
  do
    if vim.fn.isdirectory(p) == 1 then
      return p
    end
  end
  -- distro / manual (e.g. Arch `community/typescript`)
  for _, try in ipairs({ "/usr/lib/node_modules/typescript/lib", "/usr/local/lib/node_modules/typescript/lib" }) do
    if vim.fn.isdirectory(try) == 1 then
      return try
    end
  end
  return ""
end

-- Configure astro for Astro files (workspace typescript/lib via lspconfig helper; local node_modules/.bin/astro-ls when present)
vim.lsp.config("astro", {
  init_options = {
    typescript = {},
  },
  before_init = function(_, config)
    config.init_options = config.init_options or {}
    config.init_options.typescript = config.init_options.typescript or {}
    if config.init_options.typescript.tsdk and config.init_options.typescript.tsdk ~= "" then
      return
    end
    local tsdk = resolve_typescript_lib(config.root_dir)
    if tsdk ~= "" then
      config.init_options.typescript.tsdk = tsdk
      return
    end
    vim.notify(
      "astro-ls: no TypeScript SDK found. Install `typescript` in the project or globally (`npm i -g typescript`).",
      vim.log.levels.ERROR
    )
  end,
})

vim.lsp.config("mdx-analyzer", {
  cmd = { "mdx-language-server", "--stdio" },
  filetypes = { "mdx" },
  init_options = {
    typescript = {
      tsdk = vim.fn.expand("~/.local/share/mise/installs/node/25.1.0/lib/node_modules/typescript/lib"),
    },
  },
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

-- vim.lsp.config("csharp_ls", {
--   cmd = { "csharp-ls" },
--   filetypes = { "cs" },
--   init_options = {
--     AutomaticWorkspaceInit = false,
--   },
-- })
vim.lsp.config("kotlin-lsp", {
  cmd = { "kotlin-lsp.sh", "--stdio" },
  filetypes = { "kotlin" },
  root_markers = {
    "settings.gradle", -- Gradle (multi-project)
    "settings.gradle.kts", -- Gradle (multi-project)
    "pom.xml", -- Maven
    "build.gradle", -- Gradle
    "build.gradle.kts", -- Gradle
    "workspace.json", -- Used to integrate your own build system
  },
})

vim.lsp.config("dartls", {
  cmd = { "dart", "language-server", "--protocol=lsp" },
  filetypes = { "dart" },
  init_options = {
    onlyAnalyzeProjectsWithOpenFiles = true,
    suggestFromUnimportedLibraries = true,
    closingLabels = true,
    outline = true,
    flutterOutline = true,
  },
  ---@type lspconfig.settings.dartls
  settings = {
    dart = {
      completeFunctionCalls = false,
      updateImportsOnRename = true,
      showTodos = true,
      inlayHints = true,
    },
  },
})

vim.lsp.config("slangd", {
  cmd = { "slangd" },
  filetypes = { "hlsl", "shaderslang" },
  root_markers = { "slangdconfig.json", ".clang-format", ".git" },
  -- Keep slangd aligned with the buffer:
  -- • Full sync — robust vs formatter bursts.
  -- • debounce 0 — didChange flushed before BufWrite-derived autocmds (e.g. auto-save).
  -- After writes, slangd sometimes stacks duplicate TU state; BufWritePost soft-resync fixes that (autocmds).
  flags = {
    allow_incremental_sync = false,
    debounce_text_changes = 0,
  },
  settings = {
    slang = {
      predefinedMacros = {},
      inlayHints = {
        deducedTypes = true,
        parameterNames = true,
      },
    },
  },
})

-- Vim LSP enable
vim.lsp.enable("slangd", true)
vim.lsp.enable("ts_ls", false)
vim.lsp.enable("denols", true)
vim.lsp.enable("lua_ls", true)
vim.lsp.enable("gopls", true)
vim.lsp.enable("html", true)
vim.lsp.enable("cssls", true)
vim.lsp.enable("tailwindcss", true)
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
vim.lsp.enable("yamlls", true)
vim.lsp.enable("astro", true)
vim.lsp.enable("mdx_analyzer", true)
vim.lsp.enable("nimls", true)
vim.lsp.enable("kotlin-lsp", true)
vim.lsp.enable("systemd_lsp", true)

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

-- filetypes
vim.filetype.add({
  extension = {
    inc = "gas",
    s = "gas",
    S = "gas",
    gas = "gas",
  },
})

vim.api.nvim_create_user_command("TSRestart", function()
  local tsm = require("tree-sitter-manager")
  tsm._install_single(vim.bo.filetype, function() end)
  vim.treesitter.stop()
  vim.treesitter.start()
end, {})

require("mini.icons").setup({
  default = {
    -- Override default glyph for "file" category (reuse highlight group)
    -- file = { glyph = "󰈤" },
  },
  filetype = {
    gas = { glyph = "", hl = "MiniIconsRed" },
  },
})

vim.lsp.config("gasls", {
  cmd = { "gasls" },
  filetypes = { "gas" },
})
vim.lsp.enable("gasls", true)

vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd("checkhealth vim.lsp")
end, {})

vim.api.nvim_create_user_command("LspLog", function()
  local path = vim.lsp.log.get_filename()
  vim.cmd("edit " .. path)
end, {})

vim.api.nvim_create_user_command("LspLogClear", function()
  local path = vim.lsp.log.get_filename()
  vim.system({ "rm", path }, function(out) end)
end, {})
