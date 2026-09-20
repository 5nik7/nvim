local accents = {
  selected = "#242438",
  visual = "#2f4858",
  dashboard_icon = "#7a5aa4",
}

---@param colors table<string, string>
---@return table<string, table>
return function(colors)
  -- Keep the softer Macchiato grays used by the original Mocha customization.
  local macchiato = require("catppuccin.palettes").get_palette("macchiato")

  return {
    -- Editor
    Visual = { bg = accents.visual },
    Comment = { fg = macchiato.surface2 },
    NonText = { fg = colors.surface1 },
    LineNr = { fg = macchiato.surface1, bg = colors.mantle, bold = false },
    CursorLineNr = { fg = colors.flamingo, bg = accents.selected, bold = false },
    CursorLine = { bg = accents.selected },
    NotifyBackground = { bg = colors.base },
    NormalFloat = { fg = colors.text, bg = colors.base },
    FloatBorder = { fg = colors.surface0, bg = colors.base },
    FloatTitle = { fg = colors.lavender, bg = colors.base },

    -- References
    illuminatedWord = { bg = accents.selected },
    illuminatedCurWord = { bg = accents.selected },
    illuminatedWordRead = { bg = accents.selected },
    illuminatedWordText = { bg = accents.selected },
    IlluminatedWordWrite = { bg = accents.selected },
    LspReferenceRead = { bg = accents.selected },
    LspReferenceText = { bg = accents.selected },
    LspReferenceWrite = { bg = accents.selected },

    -- Statusline
    lualinedir = { fg = colors.overlay0 },
    lualine_a_normal = { fg = colors.crust },
    lualine_a_insert = { fg = colors.crust },
    lualine_a_visual = { fg = colors.crust },
    lualine_a_replace = { fg = colors.crust },
    lualine_a_command = { fg = colors.crust },
    lualine_a_terminal = { fg = colors.crust },

    -- Dashboard
    SnacksDashboardNormal = { fg = colors.text, bg = colors.base },
    SnacksDashboardHeader = { fg = colors.lavender, bg = colors.base },
    SnacksDashboardIcon = { fg = accents.dashboard_icon },
    SnacksDashboardKey = { fg = colors.pink, bg = colors.base, bold = true },
    SnacksDashboardTitle = { fg = colors.blue, bold = true },
    SnacksDashboardDesc = { fg = colors.mauve, bold = true },
    SnacksDashboardDir = { fg = colors.overlay0 },
    SnacksDashboardFile = { fg = colors.text, bold = true },
    SnacksDashboardFooter = { fg = colors.surface1 },

    -- Picker and indentation
    SnacksPickerCursorLine = { bg = accents.selected },
    SnacksPickerPrompt = { fg = colors.mauve },
    SnacksPickerListCursorLine = { bg = accents.selected },
    SnacksPickerPreviewCursorLine = { bg = accents.selected },
    SnacksPickerDir = { fg = colors.overlay0 },
    SnacksPickerDimmed = { fg = colors.overlay0 },
    SnacksPickerTotals = { fg = colors.surface1 },
    SnacksPickerMatch = { fg = colors.sky, bg = colors.mantle, bold = true, underline = true },
    SnacksIndentScope = { fg = colors.sapphire },
    SnacksIndentChunk = { fg = colors.sapphire },
    TelescopeBorder = { fg = colors.surface0 },

    -- Diagnostics and Git
    DiagnosticVirtualTextError = { fg = colors.red },
    DiagnosticVirtualTextWarn = { fg = colors.yellow },
    DiagnosticVirtualTextInfo = { fg = colors.blue },
    DiagnosticVirtualTextHint = { fg = colors.peach },
    GitSignsAdd = { fg = colors.green },
    GitSignsChange = { fg = colors.yellow },
    GitSignsDelete = { fg = colors.red },
  }
end
