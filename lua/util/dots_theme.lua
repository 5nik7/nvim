-- Compatibility entry points; Anodize owns palette loading and reload lifecycle.
local M = {}
local installed = false

local function plugin()
  local ok, value = pcall(require, "anodize")
  return ok and value or nil
end

function M.reload(_force)
  local anodize = plugin()
  if not anodize then
    return false, "Anodize.nvim unavailable"
  end
  return anodize.reload()
end

function M.install()
  if installed then
    return
  end
  installed = true
  -- Clear the old bridge's focus/resume handlers. Anodize owns these events.
  local group = vim.api.nvim_create_augroup("dots_theme", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    pattern = "anodize",
    callback = function()
      require("config.highlights.anodize").after_load()
    end,
  })
  vim.api.nvim_create_user_command("DotsThemeReload", function()
    local ok, reason = M.reload(true)
    if not ok and reason == "inactive" then
      vim.notify("dots themes: use :colorscheme anodize to activate", vim.log.levels.INFO)
    elseif not ok and reason == "Anodize.nvim unavailable" then
      vim.notify(reason .. "; check ANODIZE_NVIM_DIR or ~/repos/Anodize.nvim", vim.log.levels.WARN)
    end
  end, { desc = "Reload the active Anodize shared theme", force = true })
end

function M.startup()
  M.install()
  -- LazyVim can call its colorscheme callback before the start-plugin pass.
  local ok, lazy = pcall(require, "lazy")
  if ok then
    pcall(lazy.load, { plugins = { "anodize" } })
  end
  if plugin() then
    vim.cmd.colorscheme("anodize")
  else
    vim.notify("Anodize.nvim unavailable; set ANODIZE_NVIM_DIR or create ~/repos/Anodize.nvim", vim.log.levels.WARN)
    vim.cmd.colorscheme("habamax")
  end
end

-- Raw native colors remain available to legacy/private consumers, data only.
function M.options(opts)
  local selected = require("util.dots_theme_legacy").read()
  if selected and selected.data.theme == "catppuccin" then
    opts.flavour = selected.data.flavor
    opts.color_overrides = vim.tbl_deep_extend("force", opts.color_overrides or {}, {
      [selected.data.flavor] = selected.data.palette,
    })
  end
  return opts
end

function M.pywal_colors()
  local selected = require("util.dots_theme_legacy").read()
  assert(selected and selected.data.theme == "pywal16", "Select pywal16 through dots themes first")
  return vim.tbl_extend("force", vim.deepcopy(selected.data.palette), { transparent = "NONE" })
end

function M.gradient_colors()
  local anodize = package.loaded.anodize
  local active = anodize and anodize.get_palette()
  if active then
    local r = active.roles
    return { r.info, r.hint, r.warning, r.error, r.accent }
  end
  -- Standalone configurations follow the current colorscheme without loading a
  -- theme plugin just to obtain its palette.
  local colors = {}
  for _, name in ipairs({
    "DiagnosticInfo",
    "DiagnosticHint",
    "DiagnosticWarn",
    "DiagnosticError",
    "SnacksDashboardHeader",
  }) do
    local fg = vim.api.nvim_get_hl(0, { name = name, link = false }).fg
    if fg then
      colors[#colors + 1] = string.format("#%06x", fg)
    end
  end
  if #colors == 0 then
    local fg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg
    colors[1] = string.format("#%06x", fg or (vim.o.background == "light" and 0x000000 or 0xffffff))
  end
  return colors
end
return M
