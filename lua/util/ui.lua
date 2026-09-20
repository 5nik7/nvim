local M = {
  banners = require("util.banners"),
}

---@param item {file: string}
---@param ctx {width?: integer}
function M.format_dashboard_file(item, ctx)
  local fname = vim.fs.normalize(vim.fn.fnamemodify(item.file, ":~")):gsub("\\", "/")

  -- Shorten directory components first.
  if ctx.width and #fname > ctx.width then
    fname = vim.fn.pathshorten(fname)
  end

  -- If it is still too long, discard the directory rather than
  -- truncating the filename.
  if ctx.width and #fname > ctx.width then
    local file = vim.fn.fnamemodify(fname, ":t")
    fname = "…/" .. file
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
