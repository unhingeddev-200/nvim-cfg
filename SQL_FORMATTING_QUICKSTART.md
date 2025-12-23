# SQL Formatting Quick Start

## ✅ Setup Complete!

Your Neovim is now configured to use `sql-formatter` instead of `sqls` for formatting SQL files.

## Quick Commands

| Action | Command |
|--------|---------|
| Format current buffer | `<leader>cf` (usually `<Space>cf`) |
| Check formatter info | `:ConformInfo` |
| Format on save | Automatic (already enabled) |

## Test It Now!

1. Open the test file:
   ```vim
   :e ~/.config/nvim/test_formatter.sql
   ```

2. Press `<Space>cf` to format

3. Watch the magic happen! ✨

## What Changed?

- ✅ Installed `sql-formatter` (v15.6.12)
- ✅ Added `conform.nvim` plugin
- ✅ Disabled sqls formatting
- ✅ Created `.sql-formatter.json` config
- ✅ Configured format-on-save for SQL files

## Customization

Edit `~/.config/nvim/.sql-formatter.json` to customize:

```json
{
  "keywordCase": "upper",    // Change to "lower" for lowercase keywords
  "tabWidth": 2,             // Change to 4 for 4-space indentation
  "language": "sql"          // Change to "postgresql", "mysql", etc.
}
```

## Supported Dialects

- `sql` (standard)
- `postgresql`
- `mysql`
- `mariadb`
- `sqlite`
- `bigquery`
- `snowflake`
- `tsql` (SQL Server)
- And 12 more!

## Need Help?

See detailed documentation in:
- `SQL_FORMATTER_SETUP.md` - Full setup guide
- `FORMATTER_CHANGES.md` - What was changed

## Troubleshooting

**Formatter not working?**
1. Restart Neovim
2. Run `:Lazy sync` to install conform.nvim
3. Check `:ConformInfo` for status

**Want different formatting style?**
Edit `.sql-formatter.json` and restart Neovim

---

Happy SQL formatting! 🎉
