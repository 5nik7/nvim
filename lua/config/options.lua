vim.opt.termguicolors = true

vim.opt.wrap = true
vim.opt.smartindent = true
vim.opt.cmdheight = 0

vim.opt.mousescroll = "ver:1,hor:1"

vim.g.lazyvim_python_ruff = "ruff"
vim.g.lazyvim_python_lsp = "basedpyright"

vim.g.autoformat = true
vim.g.snacks_animate = true
vim.g.markdown_recommended_style = 0

vim.g.shfmt_opt = "-ci"

local platform = require("util.platform")
local shell = platform.shell()
if shell then
  LazyVim.terminal.setup(shell)
  if shell == "powershell" then
    -- Windows PowerShell 5.1 has no $PSStyle (used by some LazyVim revisions).
    vim.o.shellcmdflag = vim.o.shellcmdflag:gsub("%$PSStyle%.OutputRendering='plaintext';", "")
  end
end
if vim.g.clipboard == nil then
  vim.g.clipboard = platform.clipboard()
end
