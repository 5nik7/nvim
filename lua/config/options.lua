-- vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
-- vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0

if vim.fn.has("win32") == 1 then
  LazyVim.terminal.setup("pwsh")
end

if string.match(vim.loop.os_uname().release, "WSL2") then
  vim.g.clipboard = {
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
  }
end
