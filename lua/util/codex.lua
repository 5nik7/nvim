local M = {}

function M.toggle(resume)
  local termux = require("util.platform").detect().termux
  local executable = termux and "codex-termux" or "codex"
  if vim.fn.executable(executable) ~= 1 then
    local message = termux
        and "codex-termux is not on PATH. Install https://github.com/5nik7/codex-termux and run `codex-termux login`."
      or "Codex CLI is not on PATH. Install it and sign in with `codex login` first."
    vim.notify(message, vim.log.levels.WARN)
    return
  end

  local command = termux and { executable, "run" } or { executable }
  if resume then
    command[#command + 1] = "resume"
  end

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
      title = resume and " Codex Resume " or " Codex ",
      keys = {
        -- Codex uses Escape; leave terminal mode with Ctrl-\ Ctrl-n instead.
        term_normal = false,
      },
    },
  })
end

return M
