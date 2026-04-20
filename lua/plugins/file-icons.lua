-- ~/.config/nvim/lua/plugins/icons.lua
return {
  {
    "nvim-mini/mini.icons",
    opts = {
      extension = {
        -- Override highlight group (not necessary from 'mini.icons')
        -- lua = { hl = "Special" },

        -- Add icons for custom extension. This will also be used in
        -- 'file' category for input like 'file.my.ext'.
        [".s"] = { glyph = "󰻲", hl = "MiniIconsRed" },
      },
    },
  },
}
