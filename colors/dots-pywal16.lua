-- Render the immutable dots snapshot without sourcing pywal's live Vimscript.
local colors = require("util.dots_theme").pywal_colors()
vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd.syntax("reset")
end
vim.o.termguicolors = true
vim.g.colors_name = "dots-pywal16"
require("pywal16.highlights").highlight_all(colors)
