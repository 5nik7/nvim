local M = {}

function M.detect()
  local windows = vim.fn.has("win32") == 1
  local linux = vim.uv.os_uname().sysname == "Linux"
  local termux = linux
    and (vim.env.TERMUX_VERSION ~= nil or (vim.env.PREFIX or ""):find("/com.termux/", 1, true) ~= nil)
  local wsl = not windows and not termux and vim.fn.has("wsl") == 1
  return {
    windows = windows,
    termux = termux,
    wsl = wsl,
    name = windows and "Windows" or termux and "Termux" or wsl and "WSL" or vim.uv.os_uname().sysname,
  }
end

function M.has(command)
  return type(command) == "string" and command ~= "" and vim.fn.executable(command) == 1
end

-- Also inspect Mason's bin directory before its setup has added it to PATH.
function M.tool(command)
  if M.has(command) then
    return vim.fn.exepath(command)
  end
  if not M.detect().termux then
    local base = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", command)
    for _, suffix in ipairs(M.detect().windows and { ".cmd", ".exe", ".bat", "" } or { "" }) do
      if M.has(base .. suffix) then
        return base .. suffix
      end
    end
  end
end

function M.clipboard()
  local platform = M.detect()
  if platform.termux and M.has("termux-clipboard-set") and M.has("termux-clipboard-get") then
    return {
      name = "termux",
      copy = { ["+"] = { "termux-clipboard-set" }, ["*"] = { "termux-clipboard-set" } },
      paste = { ["+"] = { "termux-clipboard-get" }, ["*"] = { "termux-clipboard-get" } },
      cache_enabled = 0,
    }
  elseif platform.wsl and M.has("win32yank.exe") then
    local command = vim.fn.resolve(vim.fn.exepath("win32yank.exe"))
    return {
      name = "win32yank-wsl",
      copy = { ["+"] = { command, "-i", "--crlf" }, ["*"] = { command, "-i", "--crlf" } },
      paste = { ["+"] = { command, "-o", "--lf" }, ["*"] = { command, "-o", "--lf" } },
      cache_enabled = 0,
    }
  end
end

function M.shell()
  if M.detect().windows then
    return M.has("pwsh") and "pwsh" or M.has("powershell") and "powershell" or nil
  end
end

function M.compiler()
  if M.has(vim.env.CC) then
    return vim.env.CC
  end
  for _, command in ipairs({ "cc", "gcc", "clang", "cl" }) do
    if M.has(command) then
      return command
    end
  end
end

function M.can_build_parsers()
  return M.compiler() ~= nil and M.has("tree-sitter") and M.has("tar") and M.has("curl")
end

return M
