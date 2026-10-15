local M = {}

---@type table<string, { title: string, args: string[], connect?: boolean }>
local modes = {
  new = { title = "Codex", args = {} },
  resume = { title = "Codex Resume", args = { "resume" } },
  resume_last = { title = "Codex Resume Last", args = { "resume", "--last" } },
  connect = { title = "Codex Connect", args = {}, connect = true },
  connect_resume_last = { title = "Codex Connect Resume Last", args = { "resume", "--last" }, connect = true },
}

---@param mode? "new"|"resume"|"resume_last"|"connect"|"connect_resume_last"|boolean
function M.toggle(mode)
  -- Preserve the original toggle() / toggle(true) interface.
  local name = type(mode) == "boolean" and (mode and "resume" or "new") or mode or "new"
  local launch = assert(modes[name], "Unknown Codex launch mode: " .. tostring(name))
  local termux = require("util.platform").detect().termux
  if launch.connect and not termux then
    vim.notify("Codex server connections require codex-termux on Termux.", vim.log.levels.WARN)
    return
  end

  local executable = termux and "codex-termux" or "codex"
  if vim.fn.executable(executable) ~= 1 then
    local message = termux
        and "codex-termux is not on PATH. Install https://github.com/5nik7/codex-termux and run `codex-termux login`."
      or "Codex CLI is not on PATH. Install it and sign in with `codex login` first."
    vim.notify(message, vim.log.levels.WARN)
    return
  end

  local command = { executable }
  if termux then
    vim.list_extend(
      command,
      launch.connect and { "--wrapper-no-update", "connect", "--chatgpt" }
        or { "--wrapper-no-update", "chatgpt", "--no-daemon" }
    )
  end
  vim.list_extend(command, launch.args)

  -- Keep the project root when toggling from inside the Codex terminal itself.
  local terminal = vim.b.snacks_terminal
  local cwd = terminal and type(terminal.cmd) == "table" and terminal.cmd[1] == executable and terminal.cwd
    or LazyVim.root()

  return Snacks.terminal.toggle(command, {
    cwd = cwd,
    count = 1,
    win = {
      position = "float",
      width = 0.9,
      height = 0.85,
      border = "rounded",
      title = " " .. launch.title .. " ",
      on_buf = require("util.codex_colors").on_buf,
      keys = {
        -- Codex uses Escape; leave terminal mode with Ctrl-\ Ctrl-n instead.
        term_normal = false,
      },
    },
  })
end

return M
