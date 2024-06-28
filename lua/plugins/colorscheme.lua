return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "dark",
        floats = "dark", -- style for floating windows
      },
      on_colors = function(colors)
        local drip = require("util.dream").drip
        colors.bg = drip.bg
        colors.bg_dark = drip.bg_dark
        colors.bg_highlight = drip.bg_highlight
        colors.terminal_black = drip.terminal_black
        colors.fg_sidebar = drip.fg_sidebar
        colors.bg_sidebar = drip.bg_sidebar
        colors.bg_float = drip.bg_float
        colors.fg_gutter = drip.fg_gutter
        colors.comment = drip.comment
        colors.fg = drip.fg
        colors.blue = drip.blue
        colors.orange = drip.orange
        colors.yellow = drip.yellow
        colors.red = drip.red
      end,
      on_highlights = function(hl, c)
        hl.DashboardHeader = {
          -- bg = c.bg_dark,
          fg = c.blue,
        }
        hl.DashboardFooter = {
          -- bg = c.bg_dark,
          fg = c.comment,
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
