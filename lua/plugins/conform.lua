-- conform.nvim - Formatter plugin
-- Provides formatting for various file types
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    local util = require("conform.util")
    local fs = require("conform.fs")
    local prettier_cwd = require("conform.formatters.prettierd").cwd

    opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
      -- Prettier does not infer .astro without loading prettier-plugin-astro (project devDependency).
      astro = { "prettier_astro" },
      sql = { "sql_formatter" },
      mysql = { "sql_formatter" },
      plsql = { "sql_formatter" },
      json = { "prettier_json" },
      svg = { "prettier_svg" },
      shaderslang = { "clang_format" },
      -- BIND zone files (see :h bindzone); requires `dnsfmt` on PATH (e.g. go install github.com/miekg/dnsfmt@latest)
      bindzone = { "dnsfmt" },
      python = { "ruff_format" },
    })

    opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
      -- Same cwd/node_modules resolution as built-in `prettier`, but always load the Astro plugin.
      prettier_astro = {
        command = util.from_node_modules(fs.is_windows and "prettier.cmd" or "prettier"),
        args = { "--stdin-filepath", "$FILENAME", "--plugin", "prettier-plugin-astro" },
        cwd = prettier_cwd,
      },
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
          "postgresql",
          "--config",
          vim.fn.stdpath("config") .. "/.sql-formatter.json",
        },
        stdin = true,
      },
      dnsfmt = {
        command = "dnsfmt",
        stdin = true,
      },
    })
  end,
}
