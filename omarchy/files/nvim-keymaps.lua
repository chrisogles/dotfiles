-- Keymaps from nvim/.config/nvim/lua/config/keymaps.lua, minus the ones whose
-- tools aren't installed on an Omarchy box (gendate, textcase, GoTest) and the
-- nvim-cmp toggles (this config uses blink.cmp).
vim.keymap.set("n", "<leader>S", "<cmd>LspStop<CR>", { desc = "LspStop" })
vim.keymap.set("n", "<leader>wsq", 'ciw""<Esc>P', { desc = "Word Surround Quotes" })
vim.keymap.set("n", "<leader>rbs", "<cmd>%s/\\//g<CR>", { desc = "Replace Backward Slash" })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope symbols<cr>", { desc = "Find Symbols" })

-- keep the cursor centred when scrolling and searching
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>hy", "i{{< youtube id >}}<Esc>", { desc = "Hugo Youtube" })
