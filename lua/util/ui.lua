local M = {
  banners = require("util.banners"),
}

---@param item {file: string}
---@param ctx {width?: integer}
function M.format_dashboard_file(item, ctx)
  local fname = vim.fs.normalize(vim.fn.fnamemodify(item.file, ":~")):gsub("\\", "/")

  -- Shorten directory components first.
  if ctx.width and vim.fn.strdisplaywidth(fname) > ctx.width then
    fname = vim.fn.pathshorten(fname)
  end

  -- If it is still too long, discard the directory first.
  if ctx.width and vim.fn.strdisplaywidth(fname) > ctx.width then
    local file = vim.fn.fnamemodify(fname, ":t")
    fname = "…/" .. file
  end

  -- Keep the filename's tail when even the shortened path will not fit.
  if ctx.width and vim.fn.strdisplaywidth(fname) > ctx.width then
    local file = vim.fn.fnamemodify(fname, ":t")
    if vim.fn.strdisplaywidth(file) <= ctx.width then
      fname = file
    else
      local prefix = (".."):sub(1, math.max(0, ctx.width))
      while vim.fn.strdisplaywidth(file) > ctx.width - #prefix and file ~= "" do
        file = vim.fn.strcharpart(file, 1)
      end
      fname = prefix .. file
    end
  end

  local dir, file = fname:match("^(.*)/(.+)$")

  return dir and {
    { dir .. "/", hl = "dir" },
    { file, hl = "file" },
  } or {
    { fname, hl = "file" },
  }
end

return M
