-- local util = require("tokyonight.util")

-- local wal = require("util.wal").wal

-- local pywal16_core = require("pywal16.core")
-- local colors = pywal16_core.get_colors()

return {
  "folke/tokyonight.nvim",
  opts = {
    style = "storm",
    transparent = true,
    terminal_colors = false,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      sidebars = "transparent",
      floats = "transparent",
    },
    -- on_colors = function(colors)
    --   colors.bg = wal.background
    --   colors.bg_dark = wal.background
    --   colors.bg_statusline = wal.background
    --   colors.bg_highlight = util.lighten(wal.background, 0.95)
    --   colors.terminal_black = wal.background
    --   colors.fg = wal.foreground
    --   colors.fg_dark = util.darken(wal.foreground, 0.6)
    --   colors.fg_sidebar = wal.foreground
    --   colors.fg_float = wal.foreground
    --   colors.comment = util.lighten(wal.color8, 0.9)
    --   colors.fg_gutter = util.lighten(wal.background, 0.9)
    --   colors.border = wal.background
    --   colors.black = wal.background
    --   colors.blue = wal.color4
    --   colors.blue2 = wal.color12
    --   colors.blue3 = util.darken(wal.color4, 0.4)
    --   colors.orange = wal.color3
    --   colors.yellow = wal.color11
    --   colors.red = wal.color1
    --   colors.red1 = wal.color1
    --   colors.magenta = wal.color13
    --   colors.purple = wal.color5
    --   colors.purple2 = util.darken(wal.color5, 0.6)
    --   colors.green = wal.color10
    --   colors.green1 = wal.color2
    --   colors.green2 = util.darken(wal.color2, 0.2)
    --   colors.teal = util.darken(wal.color14, 0.5)
    --   colors.cyan = wal.color6
    --   colors.gray = wal.color8
    -- end,
    -- on_highlights = function(hl, c)
    --   hl.FzfLuaBorder = {
    --     fg = c.gray,
    --   }
    --   hl.FloatBorder = {
    --     fg = c.gray,
    --   }
    --   hl.CursorLineNr = {
    --     fg = c.purple2,
    --   }
    --   hl.NeoTreeDotFile = {
    --     fg = c.gray,
    --   }
    --   hl.NeoTreeMessage = {
    --     fg = wal.color0,
    --   }
    --   hl.NeoTreeDirectoryIcon = {
    --     fg = c.blue3,
    --   }
    --   hl.SnacksDashboardHeader = {
    --     fg = c.blue,
    --   }
    --   hl.SnacksDashboardFooter = {
    --     fg = c.gray,
    --   }
    --   hl.SnacksDashboardSpecial = {
    --     fg = c.fg_dark,
    --   }
    --   hl.SnacksDashboardKey = {
    --     fg = c.yellow,
    --   }
    --   hl.SnacksDashboardDesc = {
    --     fg = c.fg,
    --   }
    --   hl.SnacksDashboardIcon = {
    --     fg = c.gray,
    --   }
    --   hl.SnacksIndentScope = {
    --     fg = c.green2,
    --   }
    -- end,
  },
}
