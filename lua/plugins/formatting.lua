return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = { "prettierd", "prettier", "jq", stop_after_first = true },
        -- jq cannot parse comments or trailing commas.
        jsonc = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
}
