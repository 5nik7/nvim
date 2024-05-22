return
{
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
      end,
      desc = "Explorer",
    },
  },
  config = function()
  require("neo-tree").setup{
    filesystem = {
      filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = false,
      },
    },
  }
end,
}