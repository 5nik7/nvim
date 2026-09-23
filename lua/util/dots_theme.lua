-- Read immutable shared palette snapshots; no CLI calls or background polling.
local M = {}
local uv = vim.uv or vim.loop
local last_generation, failed_generation, active
local reported, installed = false, false
local supported = {
  catppuccin = { mocha = true, macchiato = true, frappe = true, latte = true },
  tokyonight = { night = true, storm = true, moon = true, day = true },
  ["rose-pine"] = { main = true, moon = true, dawn = true },
  kanagawa = { wave = true, dragon = true, lotus = true },
  gruvbox = { dark = true, light = true },
  pywal16 = { current = true },
}
local cat_roles = {
  background = "base",
  foreground = "text",
  muted = "overlay0",
  accent = "mauve",
  selection = "surface1",
  error = "red",
  warning = "yellow",
  info = "blue",
  hint = "teal",
}
local function hex(value)
  return type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil
end
local function root()
  local state = vim.env.XDG_STATE_HOME
  if not state or state == "" then
    local home = vim.env.HOME or vim.env.USERPROFILE
    if not home then
      return nil
    end
    state = home .. "/.local/state"
  end
  return state .. "/dots/themes"
end
local function read(path, limit)
  local stat = uv.fs_lstat(path)
  if not stat or stat.type ~= "file" or stat.size > limit then
    return nil
  end
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local data = file:read("*a")
  file:close()
  return data
end
local function selection()
  local state = root()
  if not state then
    return nil
  end
  local active_path = state:gsub("/themes$", "/current/theme")
  local active_link = uv.fs_readlink(active_path)
  if not active_link and not uv.fs_lstat(state .. "/current") then
    return nil
  end
  local token = active_link and (active_link:match("/(g%.[%w]+)$") or "") .. "\n" or read(state .. "/current", 128)
  if active_link and active_link ~= state .. "/generations/" .. (token:gsub("\n$", "")) then
    error("invalid active theme link")
  end
  local generation = token and token:match("^(g%.[%w]+)\n$")
  if not generation then
    error("invalid selection")
  end
  if generation == last_generation then
    return nil
  end
  local payload = read(state .. "/generations/" .. generation .. "/palette.json", 65536)
  local data = payload and vim.json.decode(payload)
  if
    type(data) ~= "table"
    or data.schema ~= 1
    or type(data.theme) ~= "string"
    or not data.theme:match("^[a-z][a-z0-9-]*$")
    or type(data.flavor) ~= "string"
    or not data.flavor:match("^[a-z][a-z0-9-]*$")
    or (data.id ~= nil and (type(data.id) ~= "string" or not data.id:match("^[a-z][a-z0-9-]*$")))
    or (data.adapter ~= "generic" and (not supported[data.theme] or not supported[data.theme][data.flavor]))
  then
    error("unsupported theme generation")
  end
  if type(data.palette) ~= "table" or next(data.palette) == nil then
    error("missing palette")
  end
  for key, color in pairs(data.palette) do
    if type(key) ~= "string" or not key:match("^[%a_][%w_]*$") or not hex(color) then
      error("invalid palette")
    end
  end
  -- Older Catppuccin generations did not contain semantic roles.
  if data.roles == nil and data.theme == "catppuccin" then
    data.roles = {}
    for role, name in pairs(cat_roles) do
      data.roles[role] = data.palette[name]
    end
  end
  if type(data.roles) ~= "table" then
    error("missing roles")
  end
  for role in pairs(cat_roles) do
    if not hex(data.roles[role]) then
      error("invalid role: " .. role)
    end
  end
  if data.theme == "pywal16" then
    for _, key in ipairs({ "background", "foreground", "cursor" }) do
      if not hex(data.palette[key]) then
        error("invalid pywal16 special color")
      end
    end
    for i = 0, 15 do
      if not hex(data.palette["color" .. i]) then
        error("invalid pywal16 color")
      end
    end
  end
  return { generation = generation, data = data }
end
local function checked_selection()
  local ok, result = pcall(selection)
  if ok then
    reported = false
    return result
  end
  if not reported then
    reported = true
    vim.schedule(function()
      vim.notify("dots themes: cannot read shared theme; keeping current colors", vim.log.levels.WARN)
    end)
  end
end
local function background(data)
  if data.mode == "light" or data.mode == "dark" then
    return data.mode
  end
  local light = { latte = true, day = true, dawn = true, lotus = true, light = true }
  if data.theme == "pywal16" then
    local color = data.roles.background
    local r, g, b = tonumber(color:sub(2, 3), 16), tonumber(color:sub(4, 5), 16), tonumber(color:sub(6, 7), 16)
    return (r * 299 + g * 587 + b * 114) >= 128000 and "light" or "dark"
  end
  return light[data.flavor] and "light" or "dark"
end
local function apply(selected)
  -- Resolve/load the plugin before modifying highlights, so missing plugins leave
  -- the current display intact and can be installed normally through Lazy.
  local action = require("util.dots_theme_adapters").prepare(selected.data)
  active = selected.data
  vim.o.background = background(active)
  action()
  -- Shared semantic colors define app chrome even when a native plugin has its
  -- own foreground or selection defaults. Keep its transparency preference.
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  normal.fg = active.roles.foreground
  if normal.bg ~= nil then
    normal.bg = active.roles.background
  end
  vim.api.nvim_set_hl(0, "Normal", normal)
  vim.api.nvim_set_hl(0, "Visual", { bg = active.roles.selection })
  vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = active.roles.accent })
  last_generation, failed_generation = selected.generation, nil
end
function M.reload(force)
  if force == true then
    last_generation, failed_generation = nil, nil
  end
  local selected = checked_selection()
  if not selected or selected.generation == failed_generation then
    return
  end
  local old_active, old_generation = active, last_generation
  local old_scheme, old_background = vim.g.colors_name, vim.o.background
  local old_highlights = vim.api.nvim_get_hl(0, {})
  local ok = pcall(apply, selected)
  if not ok then
    active, last_generation, failed_generation = old_active, old_generation, selected.generation
    pcall(function()
      vim.o.background = old_background
      if old_active then
        require("util.dots_theme_adapters").prepare(old_active)()
      elseif old_scheme then
        vim.cmd.colorscheme(old_scheme)
      end
    end)
    -- Preserve the visible state even if a plugin's rollback also fails.
    for name, hl in pairs(old_highlights) do
      pcall(vim.api.nvim_set_hl, 0, name, hl)
    end
    vim.g.colors_name = old_scheme
    vim.notify(
      "dots themes: could not apply theme; keeping previous colors. Check :Lazy, then :DotsThemeReload",
      vim.log.levels.WARN
    )
  end
end
function M.install()
  if installed then
    return
  end
  installed = true
  local group = vim.api.nvim_create_augroup("dots_theme", { clear = true })
  vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, { group = group, callback = M.reload })
  vim.api.nvim_create_user_command("DotsThemeReload", function()
    M.reload(true)
  end, { desc = "Reload the shared dots theme" })
end
function M.startup()
  M.install()
  M.reload()
  if not last_generation then
    vim.cmd.colorscheme("catppuccin-nvim")
  end
end
-- Keep the existing Catppuccin options callback available to private consumers.
function M.options(opts)
  M.install()
  local selected = checked_selection()
  if selected and selected.data.theme == "catppuccin" then
    opts.flavour = selected.data.flavor
    opts.color_overrides = vim.tbl_deep_extend("force", opts.color_overrides or {}, {
      [selected.data.flavor] = selected.data.palette,
    })
  end
  return opts
end
function M.pywal_colors()
  assert(active and active.theme == "pywal16", "Select pywal16 through dots themes first")
  return vim.tbl_extend("force", vim.deepcopy(active.palette), { transparent = "NONE" })
end
function M.gradient_colors()
  if active and active.theme ~= "catppuccin" then
    local r = active.roles
    return { r.info, r.hint, r.warning, r.error, r.accent }
  end
  local ok, palette = pcall(function()
    return require("catppuccin.palettes").get_palette()
  end)
  if not ok then
    return { "#89b4fa", "#94e2d5", "#a6e3a1", "#f9e2af", "#cba6f7" }
  end
  local colors = {}
  for _, name in ipairs({ "sapphire", "sky", "teal", "green", "yellow", "peach", "maroon", "pink", "mauve", "blue" }) do
    colors[#colors + 1] = palette[name]
  end
  return colors
end
return M
