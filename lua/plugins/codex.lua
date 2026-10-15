return {
  {
    "folke/snacks.nvim",
    init = function()
      vim.api.nvim_create_user_command("Codex", function()
        require("util.codex").toggle()
      end, { desc = "Toggle Codex (project root)" })
      vim.api.nvim_create_user_command("CodexResume", function()
        require("util.codex").toggle("resume")
      end, { desc = "Codex session picker (project root)" })
      vim.api.nvim_create_user_command("CodexResumeLast", function()
        require("util.codex").toggle("resume_last")
      end, { desc = "Resume last Codex session (project root)" })
      vim.api.nvim_create_user_command("CodexConnect", function()
        require("util.codex").toggle("connect")
      end, { desc = "Connect Codex to server (Termux)" })
      vim.api.nvim_create_user_command("CodexConnectResumeLast", function()
        require("util.codex").toggle("connect_resume_last")
      end, { desc = "Connect and resume last Codex session (Termux)" })
    end,
    keys = {
      { "<leader>ac", "<cmd>Codex<cr>", desc = "Codex (project root)" },
      { "<leader>ar", "<cmd>CodexResume<cr>", desc = "Codex session picker (project root)" },
      { "<leader>aR", "<cmd>CodexResumeLast<cr>", desc = "Resume last Codex session (project root)" },
      { "<leader>aC", "<cmd>CodexConnect<cr>", desc = "Connect Codex to server (Termux)" },
      { "<leader>aL", "<cmd>CodexConnectResumeLast<cr>", desc = "Connect and resume last Codex session (Termux)" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
}
