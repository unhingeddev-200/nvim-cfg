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
      json = { "prettier_json" },
      svg = { "prettier_svg" },
      shaderslang = { "clang_format" },
    },
    -- Custom formatter configurations
    formatters = {
      prettier_json = {
        command = "prettier",
        args = { "--parser", "json" },
      },
      prettier_svg = {
        command = "prettier",
        args = { "--parser", "html" },
      },
      sql_formatter = {
        command = "sql-formatter",
        args = {
          "--language",
          "sql", -- Can be: sql, mysql, postgresql, mariadb, etc.
          "--config",
          vim.fn.stdpath("config") .. "/.sql-formatter.json",
        },
        stdin = true,
      },
    },
  },
}
