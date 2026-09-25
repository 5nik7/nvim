-- Read immutable shared palette snapshots; no CLI calls or background polling.
local M = {}
local uv = vim.uv or vim.loop
local reported = false
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
  if uv.fs_lstat(active_path) and not active_link then
    error("invalid active theme link")
  end
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
  local payload = read(state .. "/generations/" .. generation .. "/palette.json", 65536)
  local data = payload and vim.json.decode(payload)
  if
    type(data) ~= "table"
    or data.schema ~= 1
    or type(data.theme) ~= "string"
    or not data.theme:match("^[a-z][a-z0-9_-]*$")
    or type(data.flavor) ~= "string"
    or not data.flavor:match("^[a-z][a-z0-9_-]*$")
    or (data.id ~= nil and (type(data.id) ~= "string" or not data.id:match("^[a-z][a-z0-9_-]*$")))
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
M.read = checked_selection
return M
