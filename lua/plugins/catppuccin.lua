local colors = require("catppuccin.palettes").get_palette("mocha")

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      term_colcrs = false,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.01,
      },
      nc_italic = false,
      no_bold = false,
      no_underline = false,
      styles = {
        comments = {},
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      color_overrides = {},
      custom_highlights = {
        -- Tokebns
        Comment = {
          fg = colors.surface1,
          -- bg = colors.base,
        },
        SnacksDashboardHeader = {
          fg = colors.mantle,
          -- bg = colors.mantle,
        },
        SnacksDashboardIcon = {
          fg = colors.pink,
        },
        SnacksDashboardKey = {
          fg = colors.flamingo,
        },
        SnacksDashboardTitle = {
          fg = colors.mauve,
        },
        SnacksDashboardDir = {
          fg = colors.surface2,
          -- bg = colors.mantle,
        },
        SnacksDashboardFile = {
          fg = colors.text,
          -- bg = colors.mantle,
        },
        SnacksDashboardDesc = {
          fg = colors.lavender,
          -- bg = colors.mantle,
        },
        SnacksDashboardFooter = {
          fg = colors.surface0,
        },
        SnacksDashboardSpecial = {
          fg = colors.surface1,
        },
        SnacksIndentScope = {
          fg = colors.surface2,
        },
        SnacksIndentChunk = {
          fg = colors.surface2,
        },
      },
      default_integrations = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
      },
    },
  },
}
