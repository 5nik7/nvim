return {
  {
    "folke/snacks.nvim",
    init = function()
      vim.api.nvim_create_user_command("Codex", function()
        require("util.codex").toggle()
      end, { desc = "Toggle Codex (project root)" })
      vim.api.nvim_create_user_command("CodexResume", function()
        require("util.codex").toggle(true)
      end, { desc = "Resume Codex (project root)" })
    end,
    keys = {
      { "<leader>ac", "<cmd>Codex<cr>", desc = "Codex (project root)" },
      { "<leader>ar", "<cmd>CodexResume<cr>", desc = "Resume Codex (project root)" },
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
