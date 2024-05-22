local map = vim.keymap.set

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

map('n', '<leader><space>', "<cmd>Telescope<cr>", { desc = "Telescope" })
map('n', '<leader>fb', function() require('telescope.builtin').buffers { sort_lastused = true } end, { desc = "Find Buffers" })
map('n', '<leader>ff', function() require('telescope.builtin').find_files { previewer = false } end, { desc = "Find Files" })
map('n', '<leader>fB', function() require('telescope.builtin').current_buffer_fuzzy_find() end, { desc = "Search Buffer" })
map('n', '<leader>fh', function() require('telescope.builtin').help_tags() end, { desc = "Find Help" })
map('n', '<leader>ft', function() require('telescope.builtin').tags() end, { desc = "Find Tags" })
map('n', '<leader>fd', function() require('telescope.builtin').grep_string() end, { desc = "Find Grep" })
map('n', '<leader>fp', function() require('telescope.builtin').live_grep() end, { desc = "Find live Grep" })
map('n', '<leader>fr', function() require('telescope.builtin').oldfiles() end, { desc = "Find Recent Files" })
map('n', '<leader>fH', function() require('telescope.builtin').highlights() end, { desc = "Find Highlights" })
map('n', '<leader>fk', function() require('telescope.builtin').keymaps() end, { desc = "Find Keys" })