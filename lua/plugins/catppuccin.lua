local colors = require("catppuccin.palettes").get_palette()

local c = {
  selected = "#242438",
  visual = "#2f4858",
  purple = "#a27fcd",
  purple2 = "#7a5aa4",
  black = "#000000",
}

local latte = require("catppuccin.palettes").get_palette("latte")
local frappe = require("catppuccin.palettes").get_palette("frappe")
local macchiato = require("catppuccin.palettes").get_palette("macchiato")
-- local mocha = require("catppuccin.palettes").get_palette("mocha")

-- local wal = require("pywal16.core").get_colors()

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    optional = true,
    opts = function()
      local opts = {
        flavour = "mocha",
        transparent_background = true,
        term_colors = false,
        float = {
          transparent = false,
          solid = false,
        },
        show_end_of_buffer = false,
        dim_inactive = {
          enabled = true,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
        styles = {
          comments = {},
          conditionals = {},
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
          -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
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
          Visual = {
            bg = c.visual,
          },
          lualinedir = {
            fg = colors.overlay0,
          },
          lualine_a_normal = {
            fg = colors.crust,
          },
          lualine_a_insert = {
            fg = colors.crust,
          },
          lualine_a_visual = {
            fg = colors.crust,
          },
          lualine_a_replace = {
            fg = colors.crust,
          },
          lualine_a_command = {
            fg = colors.crust,
          },
          lualine_a_terminal = {
            fg = colors.crust,
          },
          Comment = {
            fg = macchiato.surface2,
            -- bg = macchiato.mantle,
          },
          NotifyBackground = {
            bg = colors.base,
          },
          NormalFloat = {
            fg = colors.text,
            bg = colors.base,
          },
          FloatBorder = {
            fg = colors.surface0,
            bg = colors.base,
          },
          FloatTitle = {
            fg = colors.lavender,
            bg = colors.base,
          },
          illuminatedWord = {
            bg = c.selected,
          },
          illuminatedCurWord = {
            bg = c.selected,
          },
          illuminatedWordRead = {
            bg = c.selected,
          },
          illuminatedWordText = {
            bg = c.selected,
          },
          IlluminatedWordWrite = {
            bg = c.selected,
          },
          LspReferenceRead = {
            bg = c.selected,
          },
          LspReferenceText = {
            bg = c.selected,
          },
          LspReferenceWrite = {
            bg = c.selected,
          },
          LineNr = {
            fg = macchiato.surface1,
            bg = colors.mantle,
            bold = false,
          },
          CursorLineNr = {
            fg = colors.flamingo,
            bg = c.selected,
            bold = false,
          },
          CursorLine = {
            bg = c.selected,
          },
          SnacksPickerCursorLine = {
            bg = c.selected,
          },
          SnacksPickerPrompt = {
            fg = colors.mauve,
          },
          SnacksPickerListCursorLine = {
            bg = c.selected,
          },
          SnacksPickerPreviewCursorLine = {
            bg = c.selected,
          },
          SnacksDashboardNormal = {
            fg = colors.text,
            bg = colors.base,
          },
          SnacksDashboardHeader = {
            fg = colors.lavender,
            bg = colors.base,
          },
          SnacksDashboardIcon = {
            -- fg = colors.surface1,
            fg = c.purple2,
            -- bg = colors.mantle,
          },
          SnacksDashboardKey = {
            fg = colors.pink,
            bg = colors.base,
            bold = true,
          },
          SnacksDashboardTitle = {
            fg = colors.blue,
            bold = true,
          },
          SnacksDashboardDesc = {
            fg = colors.mauve,
            -- bg = colors.mantle,
            bold = true,
          },
          SnacksDashboardDir = {
            fg = colors.overlay0,
          },
          SnacksDashboardFile = {
            fg = colors.text,
            bold = true,
          },
          SnacksDashboardFooter = {
            fg = colors.surface1,
          },
          SnacksPickerDir = {
            fg = colors.overlay0,
          },
          SnacksPickerDimmed = {
            fg = colors.overlay0,
          },
          NonText = {
            fg = colors.surface1,
          },
          SnacksPickerTotals = {
            fg = colors.surface1,
          },
          SnacksPickerMatch = {
            fg = colors.sky,
            bg = colors.mantle,
            bold = true,
            underline = true,
          },
          SnacksIndentScope = {
            fg = colors.sapphire,
          },
          SnacksIndentChunk = {
            fg = colors.sapphire,
          },
          DiagnosticVirtualTextError = {
            -- bg = macchiato.crust,
            fg = colors.red,
          },
          DiagnosticVirtualTextWarn = {
            -- bg = macchiato.crust,
            fg = colors.yellow,
          },
          DiagnosticVirtualTextInfo = {
            -- bg = macchiato.crust,
            fg = colors.blue,
          },
          DiagnosticVirtualTextHint = {
            -- bg = macchiato.crust,
            fg = colors.peach,
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
          TelescopeBorder = {
            fg = colors.surface0,
          },
        },
      }
      return opts
    end,
  },
}
