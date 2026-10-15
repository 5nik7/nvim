-- nvim --headless -u NONE -i NONE -l tests/codex_colors.lua
-- Requires Python for a real PTY child; no LazyVim, Codex, or network access.
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.termguicolors = true
vim.o.background = "dark"
local colors = require("util.codex_colors")
local count = 0
local function check(value, message)
  assert(value, message)
  count = count + 1
end

local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")
vim.fn.writefile(
  vim.split(
    [[
import json, os, select, sys, time, tty
tty.setraw(0)
replies = []
for command, terminator in [(10, b'\x07'), (11, b'\x07'), (10, b'\x1b\\'), (11, b'\x1b\\')]:
    os.write(1, b'\x1b]' + str(command).encode() + b';?' + terminator)
    reply = b''
    deadline = time.monotonic() + 0.2
    while time.monotonic() < deadline:
        if select.select([0], [], [], 0.01)[0]:
            reply += os.read(0, 4096)
    replies.append(reply.decode())
with open(sys.argv[1], 'w') as output:
    json.dump(replies, output)
]],
    "\n",
    { plain = true }
  ),
  temp .. "/probe.py"
)

local palette = { roles = { background = "#1e1e2e", foreground = "#cdd6f4" } }
package.loaded.anodize = {
  get_palette = function()
    return palette
  end,
}
vim.g.colors_name = "anodize"
local before = #vim.api.nvim_get_autocmds({ event = "TermRequest" })
check(colors.install(), "default handler not found")
check(colors.install(), "install must be idempotent")
check(#vim.api.nvim_get_autocmds({ event = "TermRequest" }) == before, "handler count changed")

local function response(command, hex, terminator)
  local r, g, b = hex:match("#(%x%x)(%x%x)(%x%x)")
  return string.format("\027]%d;rgb:%s%s/%s%s/%s%s%s", command, r, r, g, g, b, b, terminator)
end

local function probe(marked, fg, bg, winhighlight)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = 0,
    col = 0,
    width = 60,
    height = 10,
    style = "minimal",
  })
  if winhighlight then
    vim.wo[win].winhighlight = winhighlight
  end
  if marked then
    colors.on_buf({ buf = buf })
  end
  local result = temp .. "/reply.json"
  local exited
  vim.fn.jobstart({ "python", temp .. "/probe.py", result }, {
    term = true,
    on_exit = function(_, code)
      exited = code
    end,
  })
  check(
    vim.wait(5000, function()
      return exited ~= nil
    end),
    "PTY probe timed out"
  )
  check(exited == 0, "PTY child failed")
  local replies = vim.json.decode(table.concat(vim.fn.readfile(result), "\n"))
  for i, terminator in ipairs({ "\007", "\027\\" }) do
    check(
      replies[i * 2 - 1] == response(10, fg, terminator),
      "wrong/duplicate foreground reply: " .. vim.inspect(replies[i * 2 - 1])
    )
    check(
      replies[i * 2] == response(11, bg, terminator),
      "wrong/duplicate background reply: " .. vim.inspect(replies[i * 2])
    )
  end
  vim.api.nvim_win_close(win, true)
  vim.api.nvim_buf_delete(buf, { force = true })
end

local ok, err = xpcall(function()
  probe(true, "#cdd6f4", "#1e1e2e")
  probe(false, "#ffffff", "#000000")
  -- Every query sees the latest palette; no cached Mocha colors.
  palette.roles = { foreground = "#575279", background = "#faf4ed" }
  vim.o.background = "light"
  probe(true, "#575279", "#faf4ed")
  probe(false, "#000000", "#ffffff")

  vim.o.background = "dark"
  vim.g.colors_name = "other"
  vim.api.nvim_set_hl(0, "Normal", { fg = "#123456", bg = "#654321" })
  vim.api.nvim_set_hl(0, "CodexTestNormal", { fg = "#abcdef", bg = "#102030" })
  probe(true, "#abcdef", "#102030", "Normal:CodexTestNormal")
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#112233", bg = "#445566" })
  probe(true, "#112233", "#445566")
  -- Transparent/missing colors must delegate, rather than fabricate a palette.
  palette = nil
  vim.g.colors_name = "anodize"
  vim.api.nvim_set_hl(0, "Normal", { fg = "#123456" })
  vim.api.nvim_set_hl(0, "NormalFloat", {})
  probe(true, "#123456", "#000000")

  -- Exercise every launcher through its real util.codex entrypoint.
  local termux, executable = true, true
  package.loaded["util.platform"] = {
    detect = function()
      return { termux = termux }
    end,
  }
  rawset(vim.fn, "executable", function()
    return executable and 1 or 0
  end)
  _G.LazyVim = {
    root = function()
      return "/project"
    end,
  }
  local calls = {}
  local terminal = { buf = vim.api.nvim_get_current_buf() }
  _G.Snacks = {
    terminal = {
      toggle = function(cmd, opts)
        calls[#calls + 1] = { cmd = cmd, opts = opts }
        opts.win.on_buf(terminal)
        check(vim.b.codex_terminal == true, "launcher did not mark terminal before spawn")
        return terminal
      end,
    },
  }
  local codex = require("util.codex")
  local modes = {
    { "new", {} },
    { "resume", { "resume" } },
    { "resume_last", { "resume", "--last" } },
    { "connect", {}, connect = true },
    { "connect_resume_last", { "resume", "--last" }, connect = true },
  }
  for _, mode in ipairs(modes) do
    check(codex.toggle(mode[1]) == terminal, "terminal return value changed")
    local call = calls[#calls]
    local expected = mode.connect and { "codex-termux", "--wrapper-no-update", "connect", "--chatgpt" }
      or { "codex-termux", "--wrapper-no-update", "chatgpt", "--no-daemon" }
    vim.list_extend(expected, mode[2])
    check(vim.deep_equal(call.cmd, expected), "launch arguments changed: " .. mode[1])
    check(call.opts.cwd == "/project" and call.opts.count == 1, "terminal identity changed")
    check(call.opts.win.keys.term_normal == false, "Escape handling changed")
  end
  vim.b.snacks_terminal = { cmd = { "codex-termux" }, cwd = "/original/project" }
  codex.toggle(true)
  check(calls[#calls].opts.cwd == "/original/project", "toggle lost terminal cwd")
  check(calls[#calls].cmd[#calls[#calls].cmd] == "resume", "boolean compatibility lost")
  vim.b.snacks_terminal = nil
  termux = false
  for _, mode in ipairs({ "new", "resume", "resume_last" }) do
    codex.toggle(mode)
    check(calls[#calls].cmd[1] == "codex", "non-Termux launcher changed")
  end
  local notices = {}
  vim.notify = function(message)
    notices[#notices + 1] = message
  end
  local launched = #calls
  codex.toggle("connect")
  executable = false
  codex.toggle()
  check(#calls == launched and #notices == 2, "unsupported/missing launch must not spawn")

  -- An unrecognized default handler must be left intact and warn only once.
  package.loaded["util.codex_colors"] = nil
  local fresh = require("util.codex_colors")
  local handlers = vim.api.nvim_get_autocmds({ event = "TermRequest" })
  check(not fresh.install() and not fresh.install(), "unexpected handler replacement")
  local remaining = vim.api.nvim_get_autocmds({ event = "TermRequest" })
  check(#remaining == #handlers, "unknown handlers changed")
  for i, handler in ipairs(handlers) do
    check(remaining[i].id == handler.id, "unknown handler was replaced")
  end
  check(#notices == 3, "missing handler must warn once")
end, debug.traceback)
vim.fn.delete(temp, "rf")
if not ok then
  error(err)
end
print("PASS: " .. count .. " Codex terminal color assertions (including real PTY replies)")
vim.cmd.qa({ bang = true })
