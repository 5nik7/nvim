vim.opt.wrap = true
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.cmdheight = 0

vim.opt.mousescroll = "ver:1,hor:1"

-- vim.g.loaded_python3_provider = 0
-- vim.g.loaded_perl_provider = 0
-- vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0

vim.g.lazyvim_python_ruff = "ruff"
vim.g.lazyvim_python_lsp = "basedpyright"

vim.g.autoformat = true
vim.g.snacks_animate = true
vim.g.markdown_recommended_style = 0

vim.g.shfmt_opt = "-ci"

if vim.fn.has("win32") == 1 then
  LazyVim.terminal.setup("pwsh")
end

vim.g.clipboard = "termux"

if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end
