-- sqls LSP plugin for SQL with database-aware completion
return {
  {
    "nanotee/sqls.nvim",
    ft = { "sql", "mysql", "plsql" },
    cmd = {
      "SqlsExecuteQuery",
      "SqlsExecuteQueryVertical",
      "SqlsShowDatabases",
      "SqlsShowSchemas",
      "SqlsShowConnections",
      "SqlsSwitchDatabase",
      "SqlsSwitchConnection",
    },
  },
}
