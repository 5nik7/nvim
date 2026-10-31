-- Published preferences are literal JSON. No shell, Lua evaluation, or plugin installation.
local M = {}
local uv = vim.uv or vim.loop
local cached, signature = {}, nil
local originals, original_globals, original_highlights = {}, {}, {}
local theme_options, applied_signature, original_diagnostics

local option_types = {
  termguicolors = "boolean",
  wrap = "boolean",
  smartindent = "boolean",
  cmdheight = "number",
  mousescroll = "string",
  number = "boolean",
  relativenumber = "boolean",
  expandtab = "boolean",
  shiftwidth = "number",
  tabstop = "number",
  softtabstop = "number",
  scrolloff = "number",
  sidescrolloff = "number",
  mouse = "string",
  signcolumn = "string",
  list = "boolean",
  listchars = "string",
}
local style_types = {
  fg = "string",
  bg = "string",
  sp = "string",
  link = "string",
  blend = "number",
  bold = "boolean",
  italic = "boolean",
  underline = "boolean",
  undercurl = "boolean",
  strikethrough = "boolean",
  reverse = "boolean",
}
local function typed_map(values, types)
  if type(values or {}) ~= "table" then
    return false
  end
  for key, value in pairs(values or {}) do
    if type(value) ~= types[key] then
      return false
    end
    if type(value) == "string" and (value:find("[%c]") or #value > 32768) then
      return false
    end
    if type(value) == "number" and (value < 0 or value > 4096 or value % 1 ~= 0) then
      return false
    end
  end
  return true
end
local function valid(candidate)
  local opts = candidate.options or {}
  if
    not typed_map(opts.options, option_types)
    or not typed_map(opts.globals, { autoformat = "boolean", snacks_animate = "boolean" })
    or not typed_map(opts.theme, { transparent = "boolean", terminal_colors = "boolean" })
  then
    return false
  end
  if
    not typed_map(opts.diagnostics, {
      virtual_text = "boolean",
      signs = "boolean",
      underline = "boolean",
      update_in_insert = "boolean",
      severity_sort = "boolean",
    })
  then
    return false
  end
  for _, group in ipairs({ "highlights", "icon_styles" }) do
    if type(opts[group] or {}) ~= "table" then
      return false
    end
    for key, fields in pairs(opts[group] or {}) do
      if type(key) ~= "string" or not key:match("^[@%w_][%w_.@:-]*$") or not typed_map(fields, style_types) then
        return false
      end
    end
  end
  local function icons(values, depth)
    if type(values) ~= "table" or depth > 6 then
      return false
    end
    for key, value in pairs(values) do
      if type(key) ~= "string" or key:find("[%c]") then
        return false
      end
      if type(value) == "table" then
        if not icons(value, depth + 1) then
          return false
        end
      elseif type(value) ~= "string" or #value > 256 or value:find("[%c]") then
        return false
      end
    end
    return true
  end
  return icons(opts.icons or {}, 0)
end

local function read()
  local root = vim.env.XDG_STATE_HOME
  if not root or root == "" then
    local home = vim.env.HOME or vim.env.USERPROFILE
    if not home then
      return cached
    end
    root = package.config:sub(1, 1) == "\\" and (vim.env.LOCALAPPDATA or home .. "/AppData/Local")
      or home .. "/.local/state"
  end
  local path = root .. "/dots/current/theme/preferences.json"
  local real = uv.fs_realpath(path)
  if not real then
    return cached
  end
  local stat = uv.fs_lstat(real)
  if not stat or stat.type ~= "file" or stat.size > 4 * 1024 * 1024 then
    return cached
  end
  local key = real .. ":" .. stat.size .. ":" .. stat.mtime.sec .. ":" .. stat.mtime.nsec
  if signature == key then
    return cached
  end
  local fd = uv.fs_open(real, "r", 0)
  if not fd then
    return cached
  end
  local raw = uv.fs_read(fd, stat.size, 0)
  uv.fs_close(fd)
  local ok, doc = pcall(vim.json.decode, raw or "", { luanil = { object = true, array = true } })
  if not ok or type(doc) ~= "table" or doc.schema ~= 1 or type(doc.apps) ~= "table" then
    return cached
  end
  local candidate = doc.apps.nvim or {}
  if
    type(candidate) ~= "table"
    or type(candidate.options or {}) ~= "table"
    or type(candidate.formatting or {}) ~= "table"
  then
    return cached
  end
  if not valid(candidate) then
    return cached
  end
  cached, signature = candidate, key
  return cached
end

function M.options()
  local prefs = read().options or {}
  for key, value in pairs(prefs.options or {}) do
    if originals[key] == nil then
      local ok, old = pcall(function()
        return vim.opt[key]:get()
      end)
      if ok then
        originals[key] = old
      end
    end
    if originals[key] ~= nil then
      pcall(function()
        vim.opt[key] = value
      end)
    end
  end
  for key, old in pairs(originals) do
    if (prefs.options or {})[key] == nil then
      pcall(function()
        vim.opt[key] = old
      end)
    end
  end
  for key, value in pairs(prefs.globals or {}) do
    if original_globals[key] == nil then
      original_globals[key] = { vim.g[key] }
    end
    vim.g[key] = value
  end
  for key, old in pairs(original_globals) do
    if (prefs.globals or {})[key] == nil then
      vim.g[key] = old[1]
    end
  end
  if prefs.diagnostics then
    original_diagnostics = original_diagnostics or vim.deepcopy(vim.diagnostic.config())
    vim.diagnostic.config(vim.tbl_deep_extend("force", vim.deepcopy(original_diagnostics), prefs.diagnostics))
  end
  local lazy = rawget(_G, "LazyVim")
  if lazy and lazy.config and lazy.config.icons then
    M.original_icons = M.original_icons or vim.deepcopy(lazy.config.icons)
    lazy.config.icons = vim.tbl_deep_extend("force", vim.deepcopy(M.original_icons), prefs.icons or {})
  end
  return prefs
end

function M.highlights()
  local prefs = M.options()
  local desired = vim.deepcopy(prefs.highlights or {})
  local diagnostic = { Error = "Error", Warn = "Warn", Info = "Info", Hint = "Hint" }
  for key, fields in pairs(prefs.icon_styles or {}) do
    local name = "DotsIcon_" .. key:gsub("[^%w_]", "_")
    desired[name] = fields
    local severity = key:match("^diagnostics%.(%w+)$")
    if severity and diagnostic[severity] then
      desired["DiagnosticSign" .. severity] = fields
    end
  end
  for key, old in pairs(original_highlights) do
    if desired[key] == nil then
      pcall(vim.api.nvim_set_hl, 0, key, old.saved)
      original_highlights[key] = nil
    end
  end
  for key, fields in pairs(desired) do
    if not original_highlights[key] then
      original_highlights[key] = {
        saved = vim.api.nvim_get_hl(0, { name = key, link = true }),
        base = vim.api.nvim_get_hl(0, { name = key, link = false }),
      }
    end
    local base = fields.link and {} or original_highlights[key].base
    local merged = vim.tbl_extend("force", base, fields)
    pcall(vim.api.nvim_set_hl, 0, key, merged)
  end
end

function M.theme(opts)
  theme_options = vim.deepcopy(opts)
  return vim.tbl_deep_extend("force", opts, read().options and read().options.theme or {})
end

function M.refresh()
  read()
  if applied_signature == signature then
    return
  end
  applied_signature = signature
  M.options()
  local anodize = package.loaded.anodize
  if anodize and theme_options then
    anodize.setup(M.theme(vim.deepcopy(theme_options)))
    if vim.g.colors_name == "anodize" then
      anodize.reload()
    end
  end
  M.highlights()
  local lualine = package.loaded.lualine
  if lualine and M.lualine_builder then
    lualine.setup(M.lualine_builder())
  end
end

function M.install()
  local group = vim.api.nvim_create_augroup("dots_config", { clear = true })
  vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, { group = group, callback = M.refresh })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      original_highlights = {}
      vim.schedule(M.highlights)
    end,
  })
end

function M.lualine(opts)
  M.options()
  local layout = (read().formatting or {}).lualine
  if not layout then
    return opts
  end
  local s = opts.sections
  local components = {
    mode = s.lualine_a[1],
    root = s.lualine_c[1],
    diagnostics = s.lualine_c[2],
    filetype = s.lualine_c[3],
    path = s.lualine_c[4],
    symbols = s.lualine_c[5],
    profiler = s.lualine_x[1],
    debug = s.lualine_x[2],
    diff = s.lualine_x[3],
    progress = s.lualine_y[1],
    location = s.lualine_y[2],
  }
  for section, names in pairs(layout.sections or {}) do
    local list = {}
    for _, name in ipairs(names) do
      local component = vim.deepcopy(components[name])
      if component then
        if layout.padding_left ~= nil or layout.padding_right ~= nil then
          component = type(component) == "table" and component or { component }
          local padding = type(component.padding) == "table" and component.padding or { left = 1, right = 1 }
          component.padding =
            { left = layout.padding_left or padding.left, right = layout.padding_right or padding.right }
        end
        list[#list + 1] = component
      end
    end
    s["lualine_" .. section] = list
  end
  for _, kind in ipairs({ "component", "section" }) do
    local key = kind .. "_separators"
    local previous = opts.options[key] or {}
    opts.options[key] = {
      left = layout[kind .. "_separator_left"] or previous.left or "",
      right = layout[kind .. "_separator_right"] or previous.right or "",
    }
  end
  return opts
end
return M
