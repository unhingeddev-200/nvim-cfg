local function pg_env(name, fallback)
  return os.getenv(name) or fallback
end

local function postgres_connection()
  return {
    alias = "postgres",
    driver = "postgresql",
    proto = "tcp",
    host = pg_env("PGHOST", "127.0.0.1"),
    user = pg_env("PGUSERNAME", "postgres"),
    passwd = pg_env("PGPASSWORD", ""),
    dbName = pg_env("PGDB", "postgres"),
    port = 5432,
    params = {
      sslmode = "disable",
    },
  }
end

---@type vim.lsp.Config
return {
  cmd = { "sqls" },
  filetypes = { "sql", "mysql", "plsql" },
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == "" then
      on_dir(vim.loop.cwd())
      return
    end
    on_dir(vim.fs.root(path, { ".git", ".sqls.yaml" }) or vim.fs.dirname(path))
  end,
  single_file_support = true,
  settings = {
    sqls = {
      connections = {
        postgres_connection(),
      },
    },
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    local client_id = client.id
    local commands = require("sqls.commands")

    vim.api.nvim_buf_create_user_command(bufnr, "SqlsExecuteQuery", function(args)
      commands.exec(client_id, "executeQuery", args.smods, args.range ~= 0, nil, args.line1, args.line2)
    end, { range = true })
    vim.api.nvim_buf_create_user_command(bufnr, "SqlsExecuteQueryVertical", function(args)
      commands.exec(client_id, "executeQuery", args.smods, args.range ~= 0, "-show-vertical", args.line1, args.line2)
    end, { range = true })
    vim.api.nvim_buf_create_user_command(bufnr, "SqlsShowDatabases", function(args)
      commands.exec(client_id, "showDatabases", args.smods)
    end, {})
    vim.api.nvim_buf_create_user_command(bufnr, "SqlsShowSchemas", function(args)
      commands.exec(client_id, "showSchemas", args.smods)
    end, {})
    vim.api.nvim_buf_create_user_command(bufnr, "SqlsShowConnections", function(args)
      commands.exec(client_id, "showConnections", args.smods)
    end, {})
    vim.api.nvim_buf_create_user_command(bufnr, "SqlsShowTables", function(args)
      commands.exec(client_id, "showTables", args.smods)
    end, {})
    vim.api.nvim_buf_create_user_command(bufnr, "SqlsSwitchDatabase", function(args)
      commands.switch_database(client_id, args.args ~= "" and args.args or nil)
    end, { nargs = "?" })
    vim.api.nvim_buf_create_user_command(bufnr, "SqlsSwitchConnection", function(args)
      commands.switch_connection(client_id, args.args ~= "" and args.args or nil)
    end, { nargs = "?" })
  end,
}
