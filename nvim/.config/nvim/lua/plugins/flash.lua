-- Move treesitter incremental selection off <C-space>.
--
-- <C-space> is the tmux prefix (see tmux/.tmux.conf), so inside tmux the key
-- never reaches nvim — the binding is dead weight on every machine that runs
-- this config over SSH. <M-space> is free in both: tmux only claims M-H/M-L
-- in its root table, and Ghostty is configured with macos-option-as-alt so
-- Option+Space sends Meta on the Mac too.
--
-- LazyVim >= 15 simulates incremental selection through flash.nvim (this
-- file). LazyVim 14.x instead uses nvim-treesitter's own incremental_selection
-- keymaps, which are rebound in plugins/treesitter.lua. Both are set so the
-- fix holds whichever version a given box is pinned to.
return {
  {
    "folke/flash.nvim",
    -- stylua: ignore
    keys = {
      { "<c-space>", false },
      { "<M-space>", mode = { "n", "o", "x" },
        function()
          require("flash").treesitter({
            actions = {
              ["<M-space>"] = "next",
              ["<BS>"] = "prev",
            },
          })
        end, desc = "Treesitter Incremental Selection" },
    },
  },
}
