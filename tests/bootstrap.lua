-- Expected to exit 1 promptly, including when plugins already exist on this host.
vim.opt.rtp:prepend(vim.fn.getcwd())
local stat, executable = vim.uv.fs_stat, vim.fn.executable
vim.uv.fs_stat = function(path)
  if path == vim.fn.stdpath("data") .. "/lazy/lazy.nvim" then
    return nil
  end
  return stat(path)
end
vim.fn.executable = function(command)
  return command == "git" and 0 or executable(command)
end
require("config.lazy")
error("bootstrap should have exited when Git was missing")
