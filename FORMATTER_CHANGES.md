# SQL Formatter Configuration Changes

## Summary

Configured Neovim to use `sql-formatter` instead of `sqls` for formatting SQL files.

## Changes Made

### 1. Added conform.nvim Plugin
**File**: `lua/plugins/conform.lua`

- Installed and configured `conform.nvim` for file formatting
- Set up `sql-formatter` for SQL, MySQL, and PL/SQL files
- Configured format-on-save with LSP fallback disabled for SQL files
- Added `<leader>cf` keybinding to manually format buffers

### 2. Disabled sqls Formatting
**File**: `init.lua`

- Modified sqls LSP configuration to disable its formatting capabilities
- Added these lines to the `on_attach` function:
  ```lua
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  ```

### 3. Created sql-formatter Configuration
**File**: `.sql-formatter.json`

- Created configuration file with sensible defaults:
  - 2-space indentation
  - Uppercase keywords, data types, and functions
  - 2 lines between queries
  - Standard indentation style

### 4. Installed sql-formatter
- Installed `sql-formatter` v15.6.12 globally via npm

## Usage

### Format Current Buffer
Press `<leader>cf` (usually `<Space>cf`)

### Format on Save
SQL files automatically format on save

### Check Formatter Status
```vim
:ConformInfo
```

## Testing

Created `test_formatter.sql` to verify formatting works correctly.

**Before formatting:**
```sql
select u.id,u.name,u.email,o.order_id,o.total from users u inner join orders o on u.id=o.user_id where u.active=1 and o.status='completed' order by o.created_at desc limit 10;
```

**After formatting:**
```sql
SELECT
  u.id,
  u.name,
  u.email,
  o.order_id,
  o.total
FROM
  users u
  INNER JOIN orders o ON u.id = o.user_id
WHERE
  u.active = 1
  AND o.status = 'completed'
ORDER BY
  o.created_at DESC
LIMIT
  10;
```

## Customization

See `SQL_FORMATTER_SETUP.md` for detailed customization options including:
- Changing SQL dialect (PostgreSQL, MySQL, etc.)
- Adjusting indentation
- Modifying keyword casing
- Alternative formatters (sqlfmt, pg_format)

## Benefits Over sqls Formatting

1. **More reliable** - Dedicated SQL formatter with better parsing
2. **Highly configurable** - Extensive formatting options
3. **Multiple dialects** - Supports 20+ SQL variants
4. **Active maintenance** - Regular updates and bug fixes
5. **Consistent results** - Predictable formatting across all SQL files

## Files Modified

- ✅ `lua/plugins/conform.lua` (created)
- ✅ `init.lua` (modified)
- ✅ `.sql-formatter.json` (created)
- ✅ `SQL_FORMATTER_SETUP.md` (created)
- ✅ `test_formatter.sql` (created for testing)

## Next Steps

1. Restart Neovim or run `:Lazy sync` to load the new plugin
2. Open any SQL file and press `<leader>cf` to test formatting
3. Customize `.sql-formatter.json` to your preferences
4. Consider adding `.sql-formatter.json` to your global gitignore if you want project-specific configs
