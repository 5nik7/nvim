return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      ---@type false | "classic" | "modern" | "helix"
      preset = "helix",
      win = {
        no_overlap = true,
      },
    },
  },
}
