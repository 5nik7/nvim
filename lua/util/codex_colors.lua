-- Supply accurate OSC 10/11 replies only to terminals opened by util.codex.
local M = {}
local attempted = false
local installed = false

local function palette_color(field)
  local anodize = package.loaded.anodize
  if vim.g.colors_name ~= "anodize" or not anodize then
    return nil
  end
  local palette = anodize.get_palette()
  local color = palette and palette.roles[field == "bg" and "background" or "foreground"]
  if type(color) == "string" and color:match("^#%x%x%x%x%x%x$") then
    return tonumber(color:sub(2), 16)
  end
end

local function highlight_color(ns, name, field)
  local seen = {}
  while not seen[name] do
    seen[name] = true
    local hl = vim.api.nvim_get_hl(ns, { name = name, link = false, create = false })
    if ns ~= 0 and vim.tbl_isempty(hl) then
      hl = vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
    end
    -- Window namespaces can return a link to a global group even with link=false.
    if not hl.link then
      return hl[field]
    end
    name = hl.link
  end
end

local function window_color(buf, field)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    local floating = vim.api.nvim_win_get_config(win).relative ~= ""
    local name = floating and "NormalFloat" or "Normal"
    local ns = vim.api.nvim_get_hl_ns({ winid = win })
    ns = math.max(ns, 0)
    -- winhighlight maps Normal even in floating windows (as Snacks does).
    -- Neovim can expose that mapping as a generated window namespace.
    for from, to in vim.wo[win].winhighlight:gmatch("([^,:]+):([^,]+)") do
      if from == "Normal" then
        name = ns == 0 and to or "Normal"
        break
      end
    end
    local color = highlight_color(ns, name, field) or highlight_color(ns, "Normal", field)
    if color ~= nil then
      return color
    end
  end
  return vim.api.nvim_get_hl(0, { name = "Normal", link = false, create = false })[field]
end

local function respond(ev)
  if not vim.b[ev.buf].codex_terminal then
    return false
  end
  local data = ev.data or {}
  local command = data.sequence == "\027]10;?" and 10 or data.sequence == "\027]11;?" and 11 or nil
  if not command then
    return false
  end
  local field = command == 10 and "fg" or "bg"
  local color = palette_color(field) or window_color(ev.buf, field)
  if color == nil then
    return false
  end
  local channel = vim.bo[ev.buf].channel
  if channel == 0 then
    return false
  end
  -- OSC uses 16-bit components: expand each 8-bit byte, rather than zero-padding it.
  local red = math.floor(color / 65536) * 257
  local green = (math.floor(color / 256) % 256) * 257
  local blue = (color % 256) * 257
  vim.api.nvim_chan_send(
    channel,
    string.format("\027]%d;rgb:%04x/%04x/%04x%s", command, red, green, blue, data.terminator)
  )
  return true
end

function M.install()
  if attempted then
    return installed
  end
  attempted = true
  local matches = {}
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = "TermRequest" })) do
    if
      autocmd.group_name == "nvim.terminal"
      and autocmd.desc == "Handles OSC foreground/background color requests"
      and autocmd.pattern == "*"
      and type(autocmd.callback) == "function"
    then
      matches[#matches + 1] = autocmd
    end
  end
  if #matches ~= 1 then
    vim.notify(
      "Codex terminal colors: Neovim's default color-query handler was not identified; leaving it unchanged.",
      vim.log.levels.WARN
    )
    return false
  end
  local original = matches[1]
  vim.api.nvim_create_autocmd("TermRequest", {
    group = original.group,
    pattern = original.pattern,
    desc = "Report theme colors to Codex terminals; delegate other requests to Neovim",
    callback = function(ev)
      if not respond(ev) then
        return original.callback(ev)
      end
    end,
  })
  vim.api.nvim_del_autocmd(original.id)
  installed = true
  return true
end

---@param win { buf: integer }
function M.on_buf(win)
  M.install()
  vim.b[win.buf].codex_terminal = true
end

return M
