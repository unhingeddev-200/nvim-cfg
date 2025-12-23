-- conform.nvim - Formatter plugin
-- Provides formatting for various file types
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    -- Define formatters by filetype
    formatters_by_ft = {
      sql = { "sql_formatter" },
      mysql = { "sql_formatter" },
      plsql = { "sql_formatter" },
    },
    -- Format on save configuration
    format_on_save = function(bufnr)
      -- Disable autoformat for SQL files if you prefer manual formatting
      -- Remove this function to enable format on save for all files
      local filetype = vim.bo[bufnr].filetype
      if filetype == "sql" or filetype == "mysql" or filetype == "plsql" then
        return {
          timeout_ms = 500,
          lsp_fallback = false, -- Don't fall back to LSP formatting (sqls)
        }
      end
      return {
        timeout_ms = 500,
        lsp_fallback = true,
      }
    end,
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
  init = function()
    -- If you want to customize format on save per filetype
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
