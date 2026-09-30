return {
  {
    "pablopunk/pi.nvim",
    cmd = { "PiAsk", "PiAskSelection", "PiCancel", "PiLog" },
    opts = {
      binary = "~/.local/bin/pi",
      provider = "openai",
      model = "gpt-6-astra",
      thinking = "medium",
    },
    keys = {
      { "<leader>ap", "<cmd>PiAsk<cr>", desc = "Ask Pi (buffer)" },
      { "<leader>ap", ":PiAskSelection<cr>", mode = "x", desc = "Ask Pi (selection)" },
      { "<leader>ax", "<cmd>PiCancel<cr>", desc = "Cancel Pi" },
      { "<leader>al", "<cmd>PiLog<cr>", desc = "Pi session log" },
    },
  },
}
