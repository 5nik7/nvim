local drip = require("util.dream").drip

return {
  "folke/tokyonight.nvim",
  opts = {
    style = "moon",
    transparent = true,
    terminal_colors = false,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      sidebars = "transparent",
      floats = "transparent",
    },
    on_colors = function(colors)
      colors.bg = drip.bg
      colors.bg_dark = drip.bg_dark
      colors.bg_statusline = drip.bg_dark
      colors.bg_highlight = drip.bg_highlight
      colors.terminal_black = drip.terminal_black
      colors.fg = drip.fg
      colors.fg_dark = drip.fg_dark
      colors.fg_sidebar = drip.fg_sidebar
      colors.fg_float = drip.fg_float
      colors.comment = drip.comment
      colors.fg_gutter = drip.fg_gutter
      colors.border = drip.border
      colors.black = drip.black
      colors.blue = drip.blue
      colors.orange = drip.orange
      colors.red = drip.red
      colors.purple = drip.purple
      colors.green = drip.green
      colors.green1 = drip.green1
      colors.cyan = drip.cyan
    end,
    on_highlights = function(hl, c)
      hl.TelescopeBorder = {
        fg = drip.fade2,
      }
      hl.CursorLineNr = {
        fg = drip.fade1,
      }
      hl.NeoTreeNormal = {
        fg = drip.fg_dark,
      }
      hl.NeoTreeFilename = {
        fg = drip.fg_dark,
      }
      hl.SnacksDashboardHeader = {
        fg = drip.blue2,
      }
      hl.SnacksDashboardFooter = {
        fg = drip.footer,
      }
      hl.SnacksDashboardSpecial = {
        fg = drip.gray,
      }
      hl.SnacksDashboardKey = {
        fg = drip.orange2,
      }
      hl.SnacksDashboardDesc = {
        fg = drip.cyan,
      }
      hl.SnacksDashboardIcon = {
        fg = drip.void,
      }
      hl.MiniIndentscopeSymbol = {
        fg = drip.gray,
      }
    end,
  },
}
