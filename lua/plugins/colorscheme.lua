return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

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
        sidebars = "transparent",
        floats = "transparent",
      },
      sidebars = { "qf", "help" },
      hide_inactive_statusline = false,
      lualine_bold = true,

      on_colors = function(colors)
        -- colors.hint = colors.orange
        colors.comment = "#303C63"
      end,

      on_highlights = function(hl, c)
        local prompt = "#303C63"
        hl.LineNr = { fg = prompt }
        hl.IblIndent = { fg = prompt }
        hl.MiniIndentscopeSymbol = { fg = "#6188FF" }
        hl.TelescopeNormal = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopePromptNormal = {
          bg = prompt,
        }
        hl.TelescopePromptBorder = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePromptTitle = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePreviewTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopeResultsTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
      end,
    },
  },

  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      styles = {
        comments = { "italic" },
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
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.50,
      },
      integrations = {
        alpha = true,
        cmp = true,
        gitsigns = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mini = {
          enabled = true,
          indentscope_color = "overlay0",
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        noice = true,
        notify = true,
        nvimtree = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
      custom_highlights = function()
        return {
          comment = { fg = "#303C63" },
          -- DashboardHeader = { fg = colors.sapphire },
          -- DashboardHeader = { fg = "#90bad3" },
          -- DashboardFooter = { fg = "#45475a" },
          -- DashboardIcon = { fg = colors.peach },
          -- DashboardDesc = { fg = colors.yellow },
          -- DashboardKey = { fg = colors.flamingo },
          -- DashboardKey = { fg = colors.pink },
          -- NeoTreeDirectoryIcon = { fg = "#45475a" },
        }
      end,
    },
  },
}
