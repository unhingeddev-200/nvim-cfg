# SQL Formatter Setup

## Overview

This Neovim configuration uses `sql-formatter` via `conform.nvim` for formatting SQL files instead of relying on `sqls` LSP's formatting capabilities.

## Installation

Install `sql-formatter` using npm (Node.js required):

```bash
npm install -g sql-formatter
```

Or using your system package manager:

**Arch Linux:**
```bash
paru -S sql-formatter  # or yay -S sql-formatter
```

**Other systems:**
Check if available in your package manager, or use npm.

## Verify Installation

```bash
sql-formatter --version
```

## Usage

### Format Current Buffer

Press `<leader>cf` (usually `<Space>cf`) to format the current SQL file.

Or use the command:
```vim
:lua require("conform").format()
```

### Format on Save

SQL files are configured to format automatically on save. If you want to disable this:

Edit `lua/plugins/conform.lua` and modify the `format_on_save` function to return `nil` for SQL files.

### Manual Format Command

You can also format using:
```vim
:ConformInfo  " Show formatter information
```

## Configuration

The formatter is configured in two places:

1. **conform.nvim** (`lua/plugins/conform.lua`) - Integrates the formatter with Neovim
2. **sql-formatter config** (`.sql-formatter.json`) - Controls formatting style

### Current Settings

The formatter is configured in `.sql-formatter.json` with:

- **Language**: SQL (standard)
- **Indentation**: 2 spaces
- **Keywords**: Uppercase
- **Data types**: Uppercase
- **Functions**: Uppercase
- **Lines between queries**: 2

### Customize Settings

Edit `.config/nvim/.sql-formatter.json`:

```json
{
  "language": "sql",           // sql, mysql, postgresql, mariadb, etc.
  "tabWidth": 2,               // Number of spaces for indentation
  "useTabs": false,            // Use spaces instead of tabs
  "keywordCase": "upper",      // upper, lower, preserve
  "dataTypeCase": "upper",     // upper, lower, preserve
  "functionCase": "upper",     // upper, lower, preserve
  "identifierCase": "preserve", // upper, lower, preserve
  "indentStyle": "standard",   // standard, tabularLeft, tabularRight
  "logicalOperatorNewline": "before", // before, after
  "expressionWidth": 50,       // Max width before breaking expressions
  "linesBetweenQueries": 2,    // Lines between queries
  "denseOperators": false,     // Remove spaces around operators
  "newlineBeforeSemicolon": false
}
```

To change the SQL dialect in `lua/plugins/conform.lua`:

```lua
formatters = {
  sql_formatter = {
    command = "sql-formatter",
    args = {
      "--language", "postgresql",  -- Change dialect
      "--config", vim.fn.stdpath("config") .. "/.sql-formatter.json",
    },
    stdin = true,
  },
},
```

## Supported SQL Dialects

- `sql` - Standard SQL
- `mysql` - MySQL
- `postgresql` - PostgreSQL
- `mariadb` - MariaDB
- `db2` - IBM DB2
- `plsql` - Oracle PL/SQL
- `n1ql` - Couchbase N1QL
- `redshift` - Amazon Redshift
- `spark` - Spark SQL
- `tsql` - Transact-SQL (SQL Server)

## Alternative Formatters

If you prefer a different SQL formatter, you can easily switch:

### sqlfmt (Python-based)

Install:
```bash
pip install sqlfmt
```

Update `lua/plugins/conform.lua`:
```lua
formatters_by_ft = {
  sql = { "sqlfmt" },
},
```

### pg_format (PostgreSQL)

Install:
```bash
# Arch Linux
sudo pacman -S pgformatter

# Ubuntu/Debian
sudo apt install pgformatter
```

Update `lua/plugins/conform.lua`:
```lua
formatters_by_ft = {
  sql = { "pg_format" },
},
formatters = {
  pg_format = {
    command = "pg_format",
    args = { "-" },
    stdin = true,
  },
},
```

## Troubleshooting

### Formatter not found

If you get an error about the formatter not being found:

1. Verify installation: `which sql-formatter`
2. Check your PATH includes the npm global bin directory
3. Restart Neovim after installation

### Formatting not working

1. Check formatter status: `:ConformInfo`
2. Verify the formatter is installed and in PATH
3. Check for errors in `:messages`

### sqls still formatting

If sqls is still trying to format, verify that `init.lua` has the formatting capabilities disabled:

```lua
on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  -- ...
end,
```

## Additional Resources

- [sql-formatter documentation](https://github.com/sql-formatter-org/sql-formatter)
- [conform.nvim documentation](https://github.com/stevearc/conform.nvim)
