return {
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
        keys = { { "<leader>0", "<cmd>Dashboard<CR>", desc = "Dashboard" } },
        config = function()
            require("plugins.config.dashboard")
        end,
    },
}
