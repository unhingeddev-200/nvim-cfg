local CONFIG_NAME = "sqls.yaml"

---@param root_dir? string
---@return string?
local function project_config(root_dir)
  if not root_dir then
    return nil
  end
  local path = vim.fs.joinpath(root_dir, CONFIG_NAME)
  if vim.uv.fs_stat(path) then
    return path
  end
  return nil
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local config_path = project_config(config.root_dir)
    local cmd = { "sqls" }
    if config_path then
      if config.root_dir then
        require("util.sqls").ensure_sqlite_databases(config_path, config.root_dir)
      end
      cmd = { "sqls", "-config", config_path }
    else
      vim.notify(
        ("sqls: no %s in project root (%s); database features require a project config file"):format(
          CONFIG_NAME,
          config.root_dir or "unknown"
        ),
        vim.log.levels.WARN
      )
    end
    if vim.fn.executable("sqls") ~= 1 then
      vim.notify("sqls binary not found", vim.log.levels.WARN)
    end
    return vim.lsp.rpc.start(cmd, dispatchers)
  end,
  filetypes = { "sql", "mysql", "plsql" },
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == "" then
      on_dir(vim.loop.cwd())
      return
    end
    on_dir(vim.fs.root(path, { CONFIG_NAME, ".git" }) or vim.fs.dirname(path))
  end,
  single_file_support = true,
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
