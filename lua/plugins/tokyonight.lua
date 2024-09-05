-- local colors = require("tokyonight.colors").setup() -- pass in any of the config options as explained above
-- local util = require("tokyonight.util")

local drip = require("util.dream").drip

return {
  "folke/tokyonight.nvim",
  opts = {
    style = "night",
    transparent = true,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      sidebars = "transparent",
      floats = "transparent",
    },
    on_colors = function(colors)
      colors.bg = drip.bg
      colors.bg_dark = drip.bg_dark
      colors.bg_highlight = drip.bg_highlight
      colors.terminal_black = drip.terminal_black
      colors.fg = drip.fg
      colors.fg_dark = drip.fg_dark
      colors.fg_sidebar = drip.fg_sidebar
      colors.fg_float = drip.fg_float
      colors.comment = drip.comment
      colors.fg_gutter = drip.fg_gutter
      colors.blue = drip.blue
      colors.orange = drip.orange
      colors.red = drip.red
      colors.purple = drip.purple
      colors.green1 = drip.green
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
      hl.DashboardHeader = {
        fg = c.blue,
      }
      hl.DashboardFooter = {
        fg = drip.comment,
      }
      hl.DashboardKey = {
        fg = c.orange,
      }
      hl.DashboardDesc = {
        fg = c.cyan,
      }
      hl.lualine_c_normal = {
        bg = c.bg_dark,
      }
      hl.current_day = {
        fg = drip.red,
      }
    end,
  },
}
