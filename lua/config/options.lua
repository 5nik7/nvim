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

-- No plugin here uses the Perl or Ruby remote-plugin hosts; skip probing them.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

local platform = require("util.platform")
local shell = platform.shell()
if shell then
  LazyVim.terminal.setup(shell)
  if shell == "powershell" then
    -- Windows PowerShell 5.1 has no $PSStyle or Remove-Alias (both PowerShell 6+).
    local flag = vim.o.shellcmdflag:gsub("%$PSStyle%.OutputRendering='plaintext';", "")
    flag = flag:gsub("Remove%-Alias %-Force %-ErrorAction SilentlyContinue tee;", function()
      return "Remove-Item -Force -ErrorAction SilentlyContinue alias:tee;"
    end)
    vim.o.shellcmdflag = flag
  end
end
if vim.g.clipboard == nil then
  vim.g.clipboard = platform.clipboard()
end

require("util.dots_config").options()
