return {
  {
    "pablopunk/pi.nvim",
    cmd = { "PiAsk", "PiAskSelection", "PiCancel", "PiLog" },
    opts = {
      binary = "~/.local/bin/pi",
      thinking = "medium",
    },
    config = function(_, opts)
      local log_dir = vim.fn.stdpath("state") .. "/pi"
      vim.fn.mkdir(log_dir, "p")
      require("pi.log").DEFAULT_PATH = log_dir .. "/session.log"
      require("pi").setup(opts)
    end,
    keys = {
      { "<leader>ap", "<cmd>PiAsk<cr>", desc = "Ask Pi (buffer)" },
      { "<leader>ap", ":PiAskSelection<cr>", mode = "x", desc = "Ask Pi (selection)" },
      { "<leader>ax", "<cmd>PiCancel<cr>", desc = "Cancel Pi" },
      { "<leader>al", "<cmd>PiLog<cr>", desc = "Pi session log" },
    },
  },
}
