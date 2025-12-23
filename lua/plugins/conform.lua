-- conform.nvim - Formatter plugin
-- Provides formatting for various file types
return {
  "stevearc/conform.nvim",
  opts = {
    -- Define formatters by filetype
    formatters_by_ft = {
      sql = { "sql_formatter" },
      mysql = { "sql_formatter" },
      plsql = { "sql_formatter" },
    },
    -- Custom formatter configurations
    formatters = {
      sql_formatter = {
        command = "sql-formatter",
        args = {
          "--language", "sql", -- Can be: sql, mysql, postgresql, mariadb, etc.
          "--config", vim.fn.stdpath("config") .. "/.sql-formatter.json",
        },
        stdin = true,
      },
    },
  },
}
