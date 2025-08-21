local colors = require("catppuccin.palettes").get_palette()
local latte = require("catppuccin.palettes").get_palette("latte")
local frappe = require("catppuccin.palettes").get_palette("frappe")
local macchiato = require("catppuccin.palettes").get_palette("macchiato")
local mocha = require("catppuccin.palettes").get_palette("mocha")

return {
  {
    "catppuccin/nvim",
    optional = true,
    opts = function()
      local bufferline = require("catppuccin.groups.integrations.bufferline")
      bufferline.get = bufferline.get or bufferline.get_theme

      local opts = {
        flavour = "mocha",
        transparent_background = true,
        term_colors = false,
        integrations = {
          aerial = true,
          alpha = true,
          cmp = true,
          dashboard = true,
          flash = true,
          fzf = true,
          grug_far = true,
          gitsigns = true,
          headlines = true,
          illuminate = true,
          indent_blankline = { enabled = true },
          leap = true,
          lsp_trouble = true,
          mason = true,
          markdown = true,
          mini = true,
          native_lsp = {
            enabled = true,
            underlines = {
              errors = { "undercurl" },
              hints = { "undercurl" },
              warnings = { "undercurl" },
              information = { "undercurl" },
            },
          },
          navic = { enabled = true, custom_bg = "lualine" },
          neotest = true,
          neotree = true,
          noice = true,
          notify = true,
          semantic_tokens = true,
          snacks = true,
          telescope = true,
          treesitter = true,
          treesitter_context = true,
          which_key = true,
        },
        custom_highlights = {
          Comment = {
            fg = colors.surface2,
          },
          CursorLine = {
            bg = macchiato.base,
          },
          illuminatedWord = {
            bg = macchiato.surface0,
          },
          illuminatedCurWord = {
            bg = macchiato.surface0,
          },
          SnacksDashboardHeader = {
            fg = macchiato.base,
          },
          SnacksDashboardIcon = {
            fg = colors.surface1,
          },
          SnacksDashboardKey = {
            fg = colors.peach,
          },
          SnacksDashboardTitle = {
            fg = colors.blue,
          },
          SnacksDashboardDir = {
            fg = colors.surface2,
          },
          SnacksDashboardFile = {
            fg = colors.text,
          },
          SnacksDashboardDesc = {
            fg = colors.text,
          },
          SnacksDashboardFooter = {
            fg = macchiato.surface1,
          },
          SnacksDashboardSpecial = {
            fg = macchiato.overlay1,
          },
          SnacksIndentScope = {
            fg = macchiato.surface2,
          },
          SnacksIndentChunk = {
            fg = macchiato.surface2,
          },
          LineNr = {
            fg = colors.surface1,
          },
          CursorLineNr = {
            fg = colors.lavender,
          },
          DiagnosticVirtualTextError = {
            bg = macchiato.crust,
            fg = colors.red,
          },
          DiagnosticVirtualTextWarn = {
            bg = macchiato.crust,
            fg = colors.yellow,
          },
          DiagnosticVirtualTextInfo = {
            bg = macchiato.crust,
            fg = colors.blue,
          },
          DiagnosticVirtualTextHint = {
            bg = macchiato.crust,
            fg = latte.teal,
          },
          GitSignsAdd = {
            fg = colors.green,
          },
          GitSignsChange = {
            fg = colors.yellow,
          },
          GitSignsDelete = {
            fg = colors.red,
          },
        },
      }

      return opts
    end,
  },
}
