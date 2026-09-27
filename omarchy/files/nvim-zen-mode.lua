-- zen-mode, lazy-loaded on :ZenMode. The repo's own spec has no lazy trigger and
-- this config sets defaults.lazy = false, so it would otherwise load at startup.
return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  opts = {},
}
