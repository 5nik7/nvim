local M = {}
local uv = vim.uv or vim.loop
local states = {}

-- Durations are in seconds; the palette is interpolated at 15 frames per second.
local cycle_duration = 5
local frame_interval = math.floor(1000 / 15)
-- A full palette spans three header diagonals. Increase this for wider color bands.
local gradient_spread = 7
-- Terminal cells are roughly twice as tall as they are wide.
local row_height = 2

local function rgb(color)
  local value = type(color) == "number" and color or tonumber(color:sub(2), 16)
  return { math.floor(value / 65536) % 256, math.floor(value / 256) % 256, value % 256 }
end

local function blend(a, b, amount)
  local result = {}
  for i = 1, 3 do
    result[i] = a[i] + (b[i] - a[i]) * amount
  end
  return result
end

local function load_colors(state)
  state.palette = {}
  for _, color in ipairs(require("util.dots_theme").gradient_colors()) do
    state.palette[#state.palette + 1] = rgb(color)
  end
  state.base = vim.api.nvim_get_hl(0, { name = "SnacksDashboardHeader", link = false })
end

local function paint(state)
  local elapsed = state.elapsed + (state.started and (uv.hrtime() - state.started) / 1e9 or 0)
  local phase = elapsed / cycle_duration
  local diagonal = math.max(1, state.width - 1 + (state.height - 1) * row_height)
  for _, cell in ipairs(state.cells) do
    local position = (cell.column - 1 + (state.height - cell.row) * row_height) / diagonal
    -- Delay each cell along the bottom-left -> top-right diagonal. Starting at
    -- peach avoids wrapping to yellow before the first color wave reaches it.
    -- Advancing time follows the palette order while the bands travel up/right.
    local offset = (math.max(0, phase - position / gradient_spread) % 1) * #state.palette
    local index = math.floor(offset)
    local color = blend(state.palette[index + 1], state.palette[(index + 1) % #state.palette + 1], offset - index)
    local highlight = vim.tbl_extend("force", state.base, {
      fg = string.format(
        "#%02x%02x%02x",
        math.floor(color[1] + 0.5),
        math.floor(color[2] + 0.5),
        math.floor(color[3] + 0.5)
      ),
    })
    vim.api.nvim_set_hl(0, cell.hl, highlight)
  end
end

local function visible(state)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == state.buf then
      return true
    end
  end
  return false
end

local function pause(state)
  if state.started then
    state.elapsed = state.elapsed + (uv.hrtime() - state.started) / 1e9
    state.started = nil
    state.timer:stop()
  end
end

local function refresh(state)
  if state.closed then
    return
  end
  if not visible(state) then
    pause(state)
  elseif not state.started then
    state.started = uv.hrtime()
    state.timer:start(
      0,
      frame_interval,
      vim.schedule_wrap(function()
        if state.closed or not state.started then
          return
        end
        if not visible(state) then
          pause(state)
          return
        end
        paint(state)
      end)
    )
  end
end

local function attach(buf)
  local state = {
    buf = buf,
    prefix = "DashboardGradient" .. buf .. "Row",
    width = 0,
    height = 0,
    cells = {},
    elapsed = 0,
    timer = assert(uv.new_timer()),
  }
  states[buf] = state
  load_colors(state)
  local group = vim.api.nvim_create_augroup("dashboard_gradient_" .. buf, { clear = true })

  local function close()
    if state.closed then
      return
    end
    pause(state)
    state.closed = true
    state.timer:close()
    states[buf] = nil
    for _, cell in ipairs(state.cells) do
      vim.api.nvim_set_hl(0, cell.hl, {})
    end
    vim.api.nvim_del_augroup_by_id(group)
  end

  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave", "TabEnter", "WinClosed" }, {
    group = group,
    callback = function()
      -- Window/tab changes must finish before testing whether the buffer is visible.
      vim.schedule(function()
        refresh(state)
      end)
    end,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      load_colors(state)
      paint(state)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, { group = group, buffer = buf, callback = close })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = close })
  return state
end

---@param dashboard snacks.dashboard.Class
---@return snacks.dashboard.Item
function M.section(dashboard)
  local header = dashboard.opts.preset.header
  if vim.g.snacks_animate == false then
    return { header = header, padding = 1 }
  end

  local state = states[dashboard.buf] or attach(dashboard.buf)
  for _, cell in ipairs(state.cells) do
    vim.api.nvim_set_hl(0, cell.hl, {})
  end
  state.cells = {}
  state.width = 0
  local texts = {}
  local lines = vim.split(header, "\n", { plain = true })
  state.height = #lines
  for row, line in ipairs(lines) do
    if row > 1 then
      texts[#texts + 1] = { "\n" }
    end
    local column = 1
    -- Split by Unicode character, not byte: the tube banner uses box-drawing glyphs.
    for _, char in ipairs(vim.fn.split(line, "\\zs")) do
      local hl = state.prefix .. row .. "Column" .. column
      state.cells[#state.cells + 1] = { row = row, column = column, hl = hl }
      texts[#texts + 1] = { char, hl = hl }
      column = column + vim.fn.strdisplaywidth(char)
    end
    state.width = math.max(state.width, column - 1)
  end
  paint(state)
  refresh(state)
  return { text = texts, padding = 1 }
end

return M
