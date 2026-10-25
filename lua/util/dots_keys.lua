-- Export only keymap metadata from this buffer; never load plugins to inspect them.
local M = {}

function M.snapshot()
  local rows = {}
  local scripts = {}
  for _, script in ipairs(vim.fn.getscriptinfo()) do
    scripts[script.sid] = script.name
  end
  for _, mode in ipairs({ "n", "i", "v", "x", "s", "o", "c", "t" }) do
    local maps = {}
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      maps[map.lhs] = { map = map, scope = "global" }
    end
    for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
      maps[map.lhs] = { map = map, scope = "buffer " .. vim.api.nvim_get_current_buf() }
    end
    for _, entry in pairs(maps) do
      local map = entry.map
      local source = scripts[map.sid]
      local line = map.lnum
      if type(map.callback) == "function" then
        local info = debug.getinfo(map.callback, "S")
        if info and info.source:sub(1, 1) == "@" then
          source = info.source:sub(2)
          line = info.linedefined
        end
      end
      rows[#rows + 1] = {
        key = vim.fn.keytrans(vim.api.nvim_replace_termcodes(map.lhs, true, true, true)),
        mode = mode,
        action = map.callback and "Lua callback" or (map.rhs or ""),
        description = map.desc or "",
        scope = entry.scope,
        source = source,
        line = line,
      }
    end
  end
  return { version = 1, app = "nvim", rows = rows }
end

function M.open()
  local dots = vim.fn.exepath("dots")
  if dots == "" and vim.fn.has("win32") == 0 then
    vim.notify("Dots is unavailable on PATH", vim.log.levels.ERROR)
    return
  end
  local file = vim.fn.tempname()
  vim.fn.writefile({ vim.json.encode(M.snapshot()) }, file)
  vim.fn.setfperm(file, "rw-------")
  local original = vim.api.nvim_get_current_win()
  vim.cmd("botright new")
  local buffer = vim.api.nvim_get_current_buf()
  vim.bo[buffer].bufhidden = "wipe"
  local args = { dots, "keys", "nvim", "--snapshot", file, "--browse" }
  if vim.fn.has("win32") == 1 then
    -- Use the native front end on Windows, never the Bash entry point.
    local root = vim.env.DOTS
    local shell = vim.fn.exepath("pwsh")
    if shell == "" then
      shell = vim.fn.exepath("powershell")
    end
    if not root or shell == "" then
      vim.fn.delete(file)
      vim.notify("Dots PowerShell entry point is unavailable", vim.log.levels.ERROR)
      return
    end
    args = { shell, "-NoProfile", "-File", root .. "/bin/dots.ps1", "keys", "nvim", "--snapshot", file, "--browse" }
  end
  local job = vim.fn.jobstart(args, {
    term = true,
    on_exit = function(_, status)
      vim.fn.delete(file)
      vim.schedule(function()
        if status == 130 and vim.api.nvim_buf_is_valid(buffer) then
          vim.api.nvim_buf_delete(buffer, { force = true })
          if vim.api.nvim_win_is_valid(original) then
            vim.api.nvim_set_current_win(original)
          end
        end
      end)
    end,
  })
  if job <= 0 then
    vim.fn.delete(file)
    vim.notify("Could not launch dots keys", vim.log.levels.ERROR)
    return
  end
  vim.cmd("startinsert")
end

return M
