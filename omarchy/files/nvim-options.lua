-- Options from nvim/.config/nvim/lua/config/options.lua. Omarchy's own file sets
-- relativenumber = false and autoformat = false above this block; both are
-- deliberately overridden here (the prettier extra expects format-on-save).
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.scrolloff = 8

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

-- search
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = false

-- splits
opt.splitright = true
opt.splitbelow = true

opt.swapfile = false

vim.g.autoformat = true
vim.g.lazygit_config = false
vim.g.netrw_liststyle = 3
