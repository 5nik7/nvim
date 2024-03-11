return {
  {
    "wallpants/github-preview.nvim",
    cmd = { "GithubPreviewToggle" },
    keys = { "<leader>mpt" },
    opts = {
      -- config goes here
    },
    config = function(_, opts)
      local gpreview = require("github-preview")
      gpreview.setup(opts)

      local fns = gpreview.fns
      vim.keymap.set("n", "<leader>mpt", fns.toggle)
      vim.keymap.set("n", "<leader>mps", fns.single_file_toggle)
      vim.keymap.set("n", "<leader>mpd", fns.details_tags_toggle)
    end,
  },

  -- {
  --   "wallpants/github-preview.nvim",
  --   -- if dev = true, lazy will look for plugin in "~/Projects/nvim-plugins"
  --   dev = true,
  --   cmd = { "GithubPreviewToggle" },
  --   opts = {
  --     log_level = "debug",
  --   },
  -- },
}
