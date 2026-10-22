-- Personal preferences belong to Dots, independent of the shared colorscheme.
local M = {}
local selected_groups = {
  "CursorLine",
  "illuminatedWord",
  "illuminatedCurWord",
  "illuminatedWordRead",
  "illuminatedWordText",
  "IlluminatedWordWrite",
  "LspReferenceRead",
  "LspReferenceText",
  "LspReferenceWrite",
  "SnacksPickerCursorLine",
  "SnacksPickerListCursorLine",
  "SnacksPickerPreviewCursorLine",
}

local function dim(color)
  local value = tonumber(color:sub(2), 16)
  return string.format(
    "#%02x%02x%02x",
    math.floor(math.floor(value / 65536) * 0.85 + 0.5),
    math.floor(math.floor(value / 256) % 256 * 0.85 + 0.5),
    math.floor(value % 256 * 0.85 + 0.5)
  )
end

function M.configure(h, c)
  for _, name in ipairs({
    "NormalFloat",
    "FloatBorder",
    "FloatTitle",
    "FloatFooter",
    "Pmenu",
    "PmenuMatch",
    "PmenuSbar",
    "SnacksNormal",
    "SnacksNormalNC",
    "SnacksWinBar",
    "SnacksWinBarNC",
    "LazyNormal",
    "MasonNormal",
    "NotifyBackground",
  }) do
    if h[name] and not h[name].link then
      h[name].bg = c.background
    end
  end
  for name, hl in pairs(h) do
    if (name:match("^SnacksNotifier") or name:match("^Notify")) and not hl.link then
      hl.bg = c.background
    end
  end
  for _, name in ipairs(selected_groups) do
    h[name] = { bg = c.lighter_background }
  end
  local preferences = {
    NormalNC = { fg = dim(c.foreground), bg = "NONE" },
    Comment = { fg = c.dark_foreground },
    NonText = { fg = c.muted },
    LineNr = { fg = c.muted, bg = c.dark_background, bold = false },
    CursorLineNr = { fg = c.accent, bg = c.lighter_background, bold = false },
    FloatBorder = { fg = c.muted, bg = c.background },
    FloatTitle = { fg = c.accent, bg = c.background },
    NotifyBackground = { bg = c.background },
    SnacksBackdrop = { bg = c.dark_background },
    lualinedir = { fg = c.muted },
    SnacksDashboardNormal = { fg = c.foreground, bg = c.background },
    SnacksDashboardHeader = { fg = c.accent, bg = c.background },
    SnacksDashboardIcon = { fg = c.accent },
    SnacksDashboardKey = { fg = c.magenta, bg = c.background, bold = true },
    SnacksDashboardTitle = { fg = c.info, bold = true },
    SnacksDashboardDesc = { fg = c.accent, bold = true },
    SnacksDashboardDir = { fg = c.muted },
    SnacksDashboardFile = { fg = c.foreground, bold = true },
    SnacksDashboardFooter = { fg = c.muted },
    SnacksPickerPrompt = { fg = c.accent },
    SnacksPickerDir = { fg = c.muted },
    SnacksPickerDimmed = { fg = c.muted },
    SnacksPickerTotals = { fg = c.muted },
    SnacksPickerMatch = { fg = c.cyan, bg = c.dark_background, bold = true, underline = true },
    SnacksIndentScope = { fg = c.hint },
    SnacksIndentChunk = { fg = c.hint },
    TelescopeBorder = { fg = c.muted, bg = c.background },
    DiagnosticVirtualTextError = { fg = c.error },
    DiagnosticVirtualTextWarn = { fg = c.warning },
    DiagnosticVirtualTextInfo = { fg = c.info },
    DiagnosticVirtualTextHint = { fg = c.hint },
  }
  for name, hl in pairs(preferences) do
    h[name] = hl
  end
end

-- Bufferline supplies complete defaults so changing surfaces preserves text styles.
function M.bufferline(defaults)
  local highlights = vim.deepcopy(defaults.highlights)
  local anodize = package.loaded.anodize
  local palette = anodize and anodize.get_palette()
  if not palette then
    return highlights
  end
  local background = palette.colors.dark_background
  local function set(name, attribute)
    if highlights[name] then
      highlights[name][attribute] = background
    end
  end
  for _, name in ipairs({
    "fill",
    "group_separator",
    "offset_separator",
    "trunc_marker",
    "background",
    "tab",
    "tab_close",
    "tab_separator",
    "indicator_visible",
  }) do
    set(name, "bg")
  end
  for _, name in ipairs({
    "buffer",
    "close_button",
    "numbers",
    "diagnostic",
    "hint",
    "hint_diagnostic",
    "info",
    "info_diagnostic",
    "warning",
    "warning_diagnostic",
    "error",
    "error_diagnostic",
    "modified",
    "duplicate",
    "pick",
    "separator",
  }) do
    set(name, "bg")
    set(name .. "_visible", "bg")
  end
  for _, name in ipairs({
    "separator",
    "separator_visible",
    "separator_selected",
    "tab_separator",
    "tab_separator_selected",
    "group_label",
    "indicator_visible",
  }) do
    set(name, "fg")
  end
  return highlights
end

function M.after_load()
  local p = require("anodize").get_palette()
  if not p or p.metadata.theme ~= "catppuccin" or p.metadata.flavor ~= "mocha" then
    return
  end
  -- Preserve deliberate Mocha exceptions without loading Catppuccin or changing roles.
  for _, name in ipairs(selected_groups) do
    vim.api.nvim_set_hl(0, name, { bg = "#242438" })
  end
  local line = vim.api.nvim_get_hl(0, { name = "CursorLineNr", link = false })
  vim.api.nvim_set_hl(0, "CursorLineNr", vim.tbl_extend("force", line, { bg = "#242438" }))
  vim.api.nvim_set_hl(0, "Comment", { fg = "#5b6078" })
  local number = vim.api.nvim_get_hl(0, { name = "LineNr", link = false })
  vim.api.nvim_set_hl(0, "LineNr", vim.tbl_extend("force", number, { fg = "#494d64" }))
end

return M
