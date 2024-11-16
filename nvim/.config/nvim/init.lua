-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.zettelkasten")
require("mason").setup()
require("nvim-treesitter.install").compilers = { "clang" }
require("plugins.obsidian")

vim.opt.runtimepath:append("/Users/chrisogilvie/.local/share/nvim/lazy/nvim-treesitter/parser")
