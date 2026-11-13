-- No plugins required: nvim --headless -u NONE -i NONE -l tests/treesitter.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
local count = 0
local function check(value, message)
  assert(value, message)
  count = count + 1
end

local calls = {}
local process = {}
local target = "aarch64-unknown-linux-android24\n"
local function system(cmd, opts, callback)
  calls[#calls + 1] = { cmd = cmd, opts = opts, callback = callback }
  if cmd[2] == "-dumpmachine" then
    return {
      wait = function()
        return { code = 0, stdout = target }
      end,
    }
  end
  return process
end
local original_env = vim.fn.environ()
vim.env.CC, vim.env.CFLAGS = nil, nil

for _, name in ipairs({ "Termux", "Linux", "WSL", "Windows" }) do
  package.loaded["util.platform"] = {
    detect = function()
      return { termux = name == "Termux" }
    end,
    compiler = function()
      return "cc"
    end,
    has = function(command)
      return command == "cc" or command == "/compiler with spaces/clang"
    end,
  }
  package.loaded["util.treesitter"] = nil
  rawset(vim, "system", system)
  local helper = require("util.treesitter")
  helper.setup()
  local wrapped = vim.system
  helper.setup()
  check(vim.system == wrapped, name .. ": setup is idempotent")

  local cmd = { "tree-sitter", "build", "-o", "parser.so" }
  local opts = { cwd = "/grammar space/λ", text = true, env = { CFLAGS = "-O2", NO_COLOR = "0" } }
  local before = vim.deepcopy(opts)
  local callback = function() end
  check(vim.system(cmd, opts, callback) == process, name .. ": process handle preserved")
  local call = calls[#calls]
  check(call.cmd == cmd and call.callback == callback, name .. ": argv and async callback preserved")
  check(vim.deep_equal(opts, before), name .. ": caller options are not mutated")
  check(call.opts.cwd == opts.cwd and call.opts.text == true, name .. ": process options preserved")
  check(
    call.opts.env.CFLAGS == (name == "Termux" and "--target=aarch64-unknown-linux-android24 -O2" or "-O2"),
    name .. ": native target added only on Termux, with custom flags retained"
  )
  check(call.opts.env.NO_COLOR == "1" and call.opts.env.CLICOLOR_FORCE == "0", name .. ": plain diagnostics")
  check(call.opts.env.CRATE_CC_NO_DEFAULTS == nil, name .. ": cc-rs optimization/PIC defaults remain enabled")

  local custom_flags = "--target=custom -O3"
  vim.system(cmd, { env = { CC = "/compiler with spaces/clang", CFLAGS = custom_flags } })
  check(calls[#calls].opts.env.CFLAGS:sub(-#custom_flags) == custom_flags, name .. ": explicit flags keep precedence")
  if name == "Termux" then
    check(calls[#calls - 1].cmd[1] == "/compiler with spaces/clang", "selected compiler path retains spaces")
    check(calls[#calls - 1].opts.timeout == 1000, "compiler probe is bounded")
  end
  vim.env.CFLAGS = "-O3"
  vim.system(cmd)
  check(
    calls[#calls].opts.env.CFLAGS == (name == "Termux" and "--target=aarch64-unknown-linux-android24 -O3" or nil),
    name .. ": inherited compiler flags preserved"
  )
  vim.system(cmd, { clear_env = true })
  check(calls[#calls].opts.clear_env == true, name .. ": clear_env preserved")
  check(
    calls[#calls].opts.env.CFLAGS == (name == "Termux" and "--target=aarch64-unknown-linux-android24" or nil),
    name .. ": clear_env does not inherit compiler flags"
  )
  vim.env.CFLAGS = nil

  local before_calls = #calls
  vim.system({ "tree-sitter", "build", "--wasm" }, opts)
  check(#calls == before_calls + 1 and calls[#calls].opts.env.CFLAGS == "-O2", name .. ": wasm target untouched")
  vim.system(cmd, { env = { CC = "sccache cc", CFLAGS = "-O1" } })
  check(calls[#calls].opts.env.CFLAGS == "-O1", name .. ": custom compiler expressions pass through")
  target = "unrecognized target\n"
  vim.system(cmd, opts)
  check(calls[#calls].opts.env.CFLAGS == "-O2", name .. ": unrecognized compiler target passes through")
  target = "aarch64-unknown-linux-android24\n"

  vim.system({ [[C:\tools with spaces\tree-sitter.exe]], "generate" }, { env = { TREE_SITTER_JS_RUNTIME = "native" } })
  check(calls[#calls].opts.env.NO_COLOR == "1", name .. ": generate diagnostics and Windows executable paths")
  check(calls[#calls].opts.env.TREE_SITTER_JS_RUNTIME == "native", name .. ": generator environment preserved")
  check(calls[#calls].opts.env.CRATE_CC_NO_DEFAULTS == nil, name .. ": no compiler workaround on generate")

  for _, other in ipairs({ { "git", "status" }, { "tree-sitter", "--version" }, { "other-tree-sitter", "build" } }) do
    vim.system(other, opts, callback)
    check(calls[#calls].opts == opts, name .. ": unrelated command options pass through unchanged")
  end
  vim.system({ "git", "status" })
  check(calls[#calls].opts == nil, name .. ": absent options stay absent")
end

local after_env = vim.fn.environ()
after_env.CC, after_env.CFLAGS = original_env.CC, original_env.CFLAGS
check(vim.deep_equal(original_env, after_env), "helper never changes the editor environment")
print("PASS: " .. count .. " Tree-sitter subprocess assertions")
